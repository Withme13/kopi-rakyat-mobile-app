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

  /// Reads a row from the POS's own `menus` table (joined with
  /// `menu_categories`) instead of the prototype's `products` schema —
  /// the POS has no slug/kind/description/origin/badge/image concept, so
  /// those are filled in with safe defaults.
  factory Product.fromMenuMap(Map<String, dynamic> map) {
    final category = map['menu_categories'] as Map<String, dynamic>?;
    return Product(
      id: map['id'] as String,
      slug: map['id'] as String,
      name: map['name'] as String,
      kind: ProductKind.drink,
      categoryKey: (category?['name'] as String?)?.toLowerCase().replaceAll(RegExp(r'\s+'), '_') ?? '',
      basePrice: (map['price'] as num).toInt(),
      description: '',
      origin: '',
      badge: null,
      imageUrl: null,
    );
  }
}
