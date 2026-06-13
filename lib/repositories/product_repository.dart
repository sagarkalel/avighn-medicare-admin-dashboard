import 'package:avighn_medicare/models/product.dart';
import 'package:avighn_medicare/services/sheets_api_service.dart';

class ProductRepository {
  final _api = SheetsApiService();

  Future<List<Product>> fetchProducts() async {
    final d = await _api.get({'action': 'getProducts'});

    if (d['success'] == true) {
      final rawList = d['data'];
      if (rawList == null) return [];

      // Apps Script returns List of Maps via sheetToObjects()
      return (rawList as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => Product.fromJson(json))
          .where((p) => p.id.isNotEmpty && p.name.isNotEmpty)
          .toList();
    }
    throw Exception(d['message'] ?? 'Failed to load products');
  }

  Future<Product> addProduct(Product p) async {
    final d = await _api.post({'action': 'addProduct', 'data': p.toSheetRow()});
    if (d['success'] == true) return p;
    throw Exception(d['message'] ?? 'Failed to add product');
  }

  Future<Product> updateProduct(Product p) async {
    final d = await _api.post({
      'action': 'updateProduct',
      'id': p.id,
      'data': p.toSheetRow(),
    });
    if (d['success'] == true) return p;
    throw Exception(d['message'] ?? 'Failed to update product');
  }

  Future<void> deleteProduct(String id) async {
    final d = await _api.post({'action': 'deleteProduct', 'id': id});
    if (d['success'] != true) {
      throw Exception(d['message'] ?? 'Failed to delete product');
    }
  }

  Future<void> toggleStock(String id, bool inStock) async {
    final d = await _api.post({
      'action': 'toggleStock',
      'id': id,
      'inStock': inStock,
    });
    if (d['success'] != true) {
      throw Exception(d['message'] ?? 'Failed to update stock');
    }
  }
}
