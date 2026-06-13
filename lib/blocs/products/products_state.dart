part of 'products_cubit.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override List<Object?> get props => [];
}
class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}
class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final int total, inStockCount, outOfStockCount;
  final List<String> categories;
  const ProductsLoaded({required this.products, required this.total, required this.inStockCount, required this.outOfStockCount, required this.categories});
  @override List<Object?> get props => [products, total, inStockCount, outOfStockCount, categories];
}
class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  @override List<Object?> get props => [message];
}
