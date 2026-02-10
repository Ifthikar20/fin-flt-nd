import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'cache_interceptor.dart';
import 'device_info_service.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final CacheInterceptor _cacheInterceptor = CacheInterceptor();
  bool _isRefreshing = false;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.plain, // Don't auto-parse JSON
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate',
        // ── Security headers for APIGuardMiddleware ──
        'X-Fynda-Mobile-Key': ApiConfig.mobileApiKey,
        'X-Fynda-Platform': DeviceInfoService.getPlatform(),
        'X-Fynda-App-Version': ApiConfig.appVersion,
      },
    ));

    // ── Response caching (GET only, 2min TTL) ─────
    _dio.interceptors.add(_cacheInterceptor);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));

    // ── Certificate Pinning ───────────────────────
    _configureCertificatePinning();
  }

  Dio get dio => _dio;

  // ─── Certificate Pinning ──────────────────────

  /// Pins TLS connections to the SHA-256 fingerprints defined in [ApiConfig].
  ///
  /// When [ApiConfig.certificatePins] is empty (e.g. during development) or
  /// in debug mode, pinning is skipped so local proxies / Charles still work.
  void _configureCertificatePinning() {
    if (ApiConfig.certificatePins.isEmpty || kDebugMode) {
      // Skip pinning in debug or when no pins configured
      return;
    }

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        // Only enforce pinning for our API host
        if (host != ApiConfig.apiHost) return true;

        // Compute SHA-256 of the certificate's DER-encoded bytes
        final digest = sha256.convert(cert.der);
        final certHash = base64Encode(digest.bytes);

        final isPinned = ApiConfig.certificatePins.contains(certHash);
        if (!isPinned) {
          debugPrint(
            '⚠️ Certificate pinning failed for $host — '
            'got $certHash but expected one of ${ApiConfig.certificatePins}',
          );
        }
        return isPinned;
      };
      return client;
    };
  }

  // ─── Interceptors ─────────────────────────────

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Manually decode JSON from the plain-text response body.
  void _onResponse(
      Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      final body = (response.data as String).trim();
      if (body.isNotEmpty) {
        try {
          response.data = jsonDecode(body);
        } catch (e) {
          debugPrint('JSON decode error: $e');
        }
      }
    }
    handler.next(response);
  }

  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    // Try to parse the error response body too
    if (error.response?.data is String) {
      final body = (error.response!.data as String).trim();
      if (body.isNotEmpty) {
        try {
          error.response!.data = jsonDecode(body);
        } catch (_) {}
      }
    }

    // Only attempt refresh for 401 on non-auth endpoints (guard against loop)
    if (error.response?.statusCode == 401 &&
        !error.requestOptions.path.contains('/auth/') &&
        !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final opts = error.requestOptions;
          final token = await _storage.read(key: _accessTokenKey);
          opts.headers['Authorization'] = 'Bearer $token';
          try {
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        } else {
          await clearTokens();
        }
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(
        responseType: ResponseType.plain,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Fynda-Mobile-Key': ApiConfig.mobileApiKey,
          'X-Fynda-Platform': DeviceInfoService.getPlatform(),
        },
      )).post(
        '${ApiConfig.baseUrl.replaceAll('/mobile', '')}/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data is String) {
        final data = jsonDecode((response.data as String).trim());
        if (data is Map) {
          await saveTokens(
            accessToken: data['access'] ?? '',
            refreshToken: refreshToken,
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return false;
  }

  // ─── Token Storage ────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _cacheInterceptor.clear(); // Wipe cached responses on logout
  }

  /// Clears all cached GET responses.
  void clearCache() => _cacheInterceptor.clear();

  /// Invalidates cached responses matching [pathPattern].
  void invalidateCache(String pathPattern) =>
      _cacheInterceptor.invalidate(pathPattern);

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null;
  }

  // ─── HTTP Methods ──────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<Response> uploadFile(String path, FormData formData) {
    return _dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: ApiConfig.imageUploadTimeout,
      ),
    );
  }
}
