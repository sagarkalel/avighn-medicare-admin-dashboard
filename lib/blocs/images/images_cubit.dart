import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/repositories/image_repository.dart';
part 'images_state.dart';

class ImagesCubit extends Cubit<ImagesState> {
  final ImageRepository _repo;
  ImagesCubit(this._repo) : super(ImagesInitial());

  Future<void> loadImages(String productId) async {
    emit(ImagesLoading());
    try { emit(ImagesLoaded(await _repo.fetchProductImages(productId))); }
    catch (e) { emit(ImagesError(e.toString())); }
  }

  Future<String?> uploadImage({required String productId, required Uint8List bytes, required String fileName, required String mimeType, bool isPrimary = false, int sortOrder = 0}) async {
    try {
      emit(ImagesUploading());
      final url = await _repo.uploadImageBase64(productId: productId, imageBytes: bytes, fileName: fileName, mimeType: mimeType, isPrimary: isPrimary, sortOrder: sortOrder);
      await loadImages(productId);
      return url;
    } catch (e) { emit(ImagesError(e.toString())); return null; }
  }

  Future<ProductImage?> addImageUrl({required String productId, required String url, bool isPrimary = false, int sortOrder = 0, String? altText}) async {
    try {
      final img = await _repo.addImageUrl(productId: productId, url: url, isPrimary: isPrimary, sortOrder: sortOrder, altText: altText);
      await loadImages(productId);
      return img;
    } catch (e) { emit(ImagesError(e.toString())); return null; }
  }

  Future<void> deleteImage(String imageId, String productId) async {
    try { await _repo.deleteImage(imageId, productId); await loadImages(productId); }
    catch (e) { emit(ImagesError(e.toString())); }
  }

  Future<void> setPrimaryImage(String imageId, String productId) async {
    try { await _repo.setPrimaryImage(imageId, productId); await loadImages(productId); }
    catch (e) { emit(ImagesError(e.toString())); }
  }
}
