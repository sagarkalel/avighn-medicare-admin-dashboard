import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:avighn_medicare/services/sheets_api_service.dart';
import 'package:mime/mime.dart';

/// Converts image bytes to base64, sends to Apps Script,
/// and returns the Google Drive public URL.
class ImageUploadService {
  static final ImageUploadService _i = ImageUploadService._();
  factory ImageUploadService() => _i;
  ImageUploadService._();

  final _api = SheetsApiService();

  Future<String> uploadBytes({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    bool isPrimary = false,
    int sortOrder = 0,
  }) async {
    final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';
    log(
      '[ImageUpload] Uploading $fileName (${(bytes.length / 1024).toStringAsFixed(1)} KB)',
    );

    final response = await _api.post({
      'action': 'uploadImage',
      'productId': productId,
      'fileName': fileName,
      'mimeType': mimeType,
      'data': base64Encode(bytes),
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
    });

    if (response['success'] == true) {
      final url = response['data']['url'] as String;
      log('[ImageUpload] Upload success → $url');
      return url;
    }
    throw Exception(response['message'] ?? 'Upload failed');
  }
}
