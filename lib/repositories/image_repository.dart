import 'dart:convert';
import 'dart:typed_data';

import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/services/sheets_api_service.dart';

class ImageRepository {
  final _api = SheetsApiService();

  Future<List<ProductImage>> fetchProductImages(String productId) async {
    final d = await _api.get({'action': 'getImages', 'productId': productId});
    if (d['success'] == true) {
      final rawList = d['data'];
      if (rawList == null) return [];
      return (rawList as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductImage.fromJson(json))
          .toList();
    }
    throw Exception(d['message'] ?? 'Failed to load images');
  }

  Future<String> uploadImageBase64({
    required String productId,
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    bool isPrimary = false,
    int sortOrder = 0,
  }) async {
    final d = await _api.post({
      'action': 'uploadImage',
      'productId': productId,
      'fileName': fileName,
      'mimeType': mimeType,
      'data': base64Encode(imageBytes),
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
    });
    if (d['success'] == true) return d['data']['url'] as String;
    throw Exception(d['message'] ?? 'Failed to upload image');
  }

  Future<ProductImage> addImageUrl({
    required String productId,
    required String url,
    bool isPrimary = false,
    int sortOrder = 0,
    String? altText,
  }) async {
    final imgId = 'img-${DateTime.now().millisecondsSinceEpoch}';
    final d = await _api.post({
      'action': 'addImageUrl',
      'imageId': imgId,
      'productId': productId,
      'url': url,
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
      'altText': altText ?? '',
    });
    if (d['success'] == true) {
      return ProductImage(
        imageId: imgId,
        productId: productId,
        url: url,
        altText: altText,
        sortOrder: sortOrder,
        isPrimary: isPrimary,
      );
    }
    throw Exception(d['message'] ?? 'Failed to add image URL');
  }

  Future<void> deleteImage(String imageId, String productId) async {
    final d = await _api.post({
      'action': 'deleteImage',
      'imageId': imageId,
      'productId': productId,
    });
    if (d['success'] != true) {
      throw Exception(d['message'] ?? 'Failed to delete image');
    }
  }

  Future<void> setPrimaryImage(String imageId, String productId) async {
    final d = await _api.post({
      'action': 'setPrimaryImage',
      'imageId': imageId,
      'productId': productId,
    });
    if (d['success'] != true) {
      throw Exception(d['message'] ?? 'Failed to set primary image');
    }
  }
}
