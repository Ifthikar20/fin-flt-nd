import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Provides a stable, persistent device identifier.
///
/// Uses the platform's native device ID:
/// - iOS: `identifierForVendor` (persists until app uninstall)
/// - Android: `id` (Android ID, persists across app installs)
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  /// Returns a stable device ID. Caches after first call.
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor ?? _fallbackId();
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedDeviceId = androidInfo.id;
      } else {
        _cachedDeviceId = _fallbackId();
      }
    } catch (_) {
      _cachedDeviceId = _fallbackId();
    }

    return _cachedDeviceId!;
  }

  /// Returns the platform name for the current device.
  static String getPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  static String _fallbackId() =>
      'flutter_${DateTime.now().millisecondsSinceEpoch}';
}
