import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPercentage;
  final String brand;
  final List<String> imageUrls;
  final String category;
  final String dosage;
  final String uses;
  final bool prescriptionRequired;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPercentage = 0,
    required this.brand,
    this.imageUrls = const [],
    required this.category,
    this.dosage = '',
    this.uses = '',
    this.prescriptionRequired = false,
    this.inStock = true,
  });

  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    return price - (price * discountPercentage / 100);
  }

  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPercentage,
    String? brand,
    List<String>? imageUrls,
    String? category,
    String? dosage,
    String? uses,
    bool? prescriptionRequired,
    bool? inStock,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    discountPercentage: discountPercentage ?? this.discountPercentage,
    brand: brand ?? this.brand,
    imageUrls: imageUrls ?? this.imageUrls,
    category: category ?? this.category,
    dosage: dosage ?? this.dosage,
    uses: uses ?? this.uses,
    prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
    inStock: inStock ?? this.inStock,
  );

  /// Parse a Map returned by Apps Script's sheetToObjects()
  factory Product.fromJson(Map<String, dynamic> json) {
    String s(String k) => json[k]?.toString().trim() ?? '';

    final rawUrls = s('imageUrls');
    final urls = rawUrls.isEmpty
        ? <String>[]
        : rawUrls
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    // prescriptionRequired / inStock can arrive as bool (json) or String ("TRUE"/"FALSE")
    bool parseBool(String key, {bool defaultVal = false}) {
      final v = json[key];
      if (v is bool) return v;
      final str = v?.toString().trim().toLowerCase() ?? '';
      if (str == 'true') return true;
      if (str == 'false') return false;
      return defaultVal;
    }

    double parseDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return Product(
      id: s('id'),
      name: s('name'),
      description: s('description'),
      price: parseDouble('price'),
      discountPercentage: parseDouble('discountPercentage'),
      brand: s('brand'),
      imageUrls: urls,
      category: s('category'),
      dosage: s('dosage'),
      uses: s('uses'),
      prescriptionRequired: parseBool('prescriptionRequired'),
      inStock: parseBool('inStock', defaultVal: true),
    );
  }

  Map<String, dynamic> toSheetRow() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price.toString(),
    'discountPercentage': discountPercentage.toString(),
    'brand': brand,
    'imageUrls': imageUrls.join(','),
    'category': category,
    'dosage': dosage,
    'uses': uses,
    'prescriptionRequired': prescriptionRequired.toString().toUpperCase(),
    'inStock': inStock.toString().toUpperCase(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    discountPercentage,
    brand,
    imageUrls,
    category,
    dosage,
    uses,
    prescriptionRequired,
    inStock,
  ];
}

class ProductImage extends Equatable {
  final String imageId;
  final String productId;
  final String url;
  final String? altText;
  final int sortOrder;
  final bool isPrimary;

  const ProductImage({
    required this.imageId,
    required this.productId,
    required this.url,
    this.altText,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    String s(String k) => json[k]?.toString().trim() ?? '';
    bool parseBool(String key) {
      final v = json[key];
      if (v is bool) return v;
      return v?.toString().trim().toLowerCase() == 'true';
    }

    return ProductImage(
      imageId: s('imageId'),
      productId: s('productId'),
      url: s('url'),
      altText: s('altText').isEmpty ? null : s('altText'),
      sortOrder: int.tryParse(s('sortOrder')) ?? 0,
      isPrimary: parseBool('isPrimary'),
    );
  }

  Map<String, dynamic> toJson() => {
    'imageId': imageId,
    'productId': productId,
    'url': url,
    'altText': altText ?? '',
    'sortOrder': sortOrder,
    'isPrimary': isPrimary,
  };

  @override
  List<Object?> get props => [imageId, productId, url, sortOrder, isPrimary];
}
