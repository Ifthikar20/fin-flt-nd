import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Calls the backend to remove the background from an image.
class BackgroundRemovalService {
  final ApiClient _api;

  BackgroundRemovalService(this._api);

  /// Remove the background from a local [imageFile].
  /// Returns the transparent PNG bytes.
  Future<Uint8List?> removeBackgroundFromFile(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.png',
        ),
      });
      final response = await _api.uploadFile('/tools/remove-bg/', formData);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final b64 = data['image_base64'] as String;
        return base64Decode(b64);
      }
    } catch (e) {
      debugPrint('Background removal failed: $e');
    }
    return null;
  }

  /// Remove the background from image [bytes] (e.g. from a network image).
  /// Writes to a temp file, calls the API, then cleans up.
  Future<Uint8List?> removeBackgroundFromBytes(Uint8List bytes) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File(
        '${tempDir.path}/rembg_${DateTime.now().millisecondsSinceEpoch}.png');
    try {
      await tempFile.writeAsBytes(bytes);
      return await removeBackgroundFromFile(tempFile);
    } finally {
      if (await tempFile.exists()) await tempFile.delete();
    }
  }
}
