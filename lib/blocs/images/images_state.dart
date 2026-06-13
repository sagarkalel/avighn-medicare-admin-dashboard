part of 'images_cubit.dart';

abstract class ImagesState extends Equatable {
  const ImagesState();
  @override List<Object?> get props => [];
}
class ImagesInitial extends ImagesState {}
class ImagesLoading extends ImagesState {}
class ImagesUploading extends ImagesState {}
class ImagesLoaded extends ImagesState {
  final List<ProductImage> images;
  const ImagesLoaded(this.images);
  @override List<Object?> get props => [images];
}
class ImagesError extends ImagesState {
  final String message;
  const ImagesError(this.message);
  @override List<Object?> get props => [message];
}
