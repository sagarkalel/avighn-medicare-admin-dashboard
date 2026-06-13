import 'dart:developer';

import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/repositories/product_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _repo;
  List<Product> _all = [];
  String _q = '', _cat = '', _stock = '';

  ProductsCubit(this._repo) : super(ProductsInitial());

  Future<void> loadProducts() async {
    emit(ProductsLoading());
    try {
      _all = await _repo.fetchProducts();
      _apply();
    } catch (e, s) {
      log("$e", stackTrace: s);
      emit(ProductsError(e.toString()));
    }
  }

  void search(String q) {
    _q = q.toLowerCase();
    _apply();
  }

  void filterByCategory(String c) {
    _cat = c;
    _apply();
  }

  void filterByStock(String s) {
    _stock = s;
    _apply();
  }

  void clearFilters() {
    _q = '';
    _cat = '';
    _stock = '';
    _apply();
  }

  void _apply() {
    var f = List<Product>.from(_all);
    if (_q.isNotEmpty) {
      f = f
          .where(
            (p) =>
                p.name.toLowerCase().contains(_q) ||
                p.brand.toLowerCase().contains(_q) ||
                p.category.toLowerCase().contains(_q) ||
                p.description.toLowerCase().contains(_q),
          )
          .toList();
    }
    if (_cat.isNotEmpty) f = f.where((p) => p.category == _cat).toList();
    if (_stock == 'inStock') {
      f = f.where((p) => p.inStock).toList();
    } else if (_stock == 'outOfStock') {
      f = f.where((p) => !p.inStock).toList();
    }
    final cats =
        _all.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()
          ..sort();
    emit(
      ProductsLoaded(
        products: f,
        total: _all.length,
        inStockCount: _all.where((p) => p.inStock).length,
        outOfStockCount: _all.where((p) => !p.inStock).length,
        categories: cats,
      ),
    );
  }

  Future<void> addProduct(Product p) async {
    try {
      await _repo.addProduct(p);
      _all.insert(0, p);
      _apply();
    } catch (e, s) {
      log("$e", stackTrace: s);
      emit(ProductsError(e.toString()));
      _apply();
    }
  }

  Future<void> updateProduct(Product p) async {
    try {
      await _repo.updateProduct(p);
      final i = _all.indexWhere((x) => x.id == p.id);
      if (i != -1) _all[i] = p;
      _apply();
    } catch (e, s) {
      log("$e", stackTrace: s);
      emit(ProductsError(e.toString()));
      _apply();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      emit(ProductsLoading());
      await _repo.deleteProduct(id);
      _all.removeWhere((p) => p.id == id);
      _apply();
    } catch (e, s) {
      log("$e", stackTrace: s);
      emit(ProductsError(e.toString()));
      _apply();
    }
  }

  Future<void> toggleStock(String id, bool inStock) async {
    final i = _all.indexWhere((p) => p.id == id);
    if (i != -1) {
      _all[i] = _all[i].copyWith(inStock: inStock);
      _apply();
    }
    try {
      await _repo.toggleStock(id, inStock);
    } catch (e, s) {
      log("$e", stackTrace: s);
      if (i != -1) {
        _all[i] = _all[i].copyWith(inStock: !inStock);
        _apply();
      }
    }
  }
}
