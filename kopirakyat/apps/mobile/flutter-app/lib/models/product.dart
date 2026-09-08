enum ProductKind { drink, merch }

class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    required this.categoryKey,
    required this.basePrice,
    required this.description,
    required this.origin,
    this.badge,
    this.imageUrl,
  });

  final String id;
  final String slug;
  final String name;
  final ProductKind kind;
  final String categoryKey;
  final int basePrice;
  final String description;
  final String origin;
  final String? badge;
  final String? imageUrl;

  String get initial => name.isNotEmpty ? name[0] : '?';

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      slug: map['slug'] as String,
      name: map['name'] as String,
      kind: (map['kind'] as String) == 'merch' ? ProductKind.merch : ProductKind.drink,
      categoryKey: (map['categories']?['key'] as String?) ?? '',
      basePrice: map['base_price'] as int,
      description: map['description'] as String? ?? '',
      origin: map['origin'] as String? ?? '',
      badge: map['badge'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }
}
