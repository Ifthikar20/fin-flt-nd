import 'dart:collection';
import 'package:dio/dio.dart';

/// In-memory LRU cache for GET responses.
///
/// Caches successful GET responses for [defaultTtl] to avoid
/// repeated identical network requests. POST/PATCH/DELETE bypass the cache.
class CacheInterceptor extends Interceptor {
  final int maxEntries;
  final Duration defaultTtl;

  final _cache = <String, _CacheEntry>{};

  CacheInterceptor({
    this.maxEntries = 100,
    this.defaultTtl = const Duration(minutes: 2),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method != 'GET') {
      handler.next(options);
      return;
    }

    final key = _cacheKey(options);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      // Cache HIT — return cached response without hitting network
      handler.resolve(
        Response(
          requestOptions: options,
          data: entry.data,
          statusCode: entry.statusCode,
          headers: entry.headers,
        ),
        true, // call next interceptor
      );
      return;
    }

    // Cache MISS — proceed with network request
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET responses
    if (response.requestOptions.method == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = _cacheKey(response.requestOptions);

      // Evict oldest entry if cache is full
      if (_cache.length >= maxEntries) {
        _cache.remove(_cache.keys.first);
      }

      _cache[key] = _CacheEntry(
        data: response.data,
        statusCode: response.statusCode!,
        headers: response.headers,
        expiresAt: DateTime.now().add(defaultTtl),
      );
    }

    handler.next(response);
  }

  /// Clears the entire cache (e.g. on logout).
  void clear() => _cache.clear();

  /// Invalidates a specific path pattern from the cache.
  void invalidate(String pathPattern) {
    _cache.removeWhere((key, _) => key.contains(pathPattern));
  }

  String _cacheKey(RequestOptions options) {
    final params = options.queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final paramStr = params.map((e) => '${e.key}=${e.value}').join('&');
    return '${options.path}?$paramStr';
  }
}

class _CacheEntry {
  final dynamic data;
  final int statusCode;
  final Headers headers;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
