import 'product.dart';

/// A configured line in the (client-side) cart. `uid` is a local-only
/// identity so quantity +/- and remove can target one line even when two
/// lines share the same product+options.
class CartLine {
  CartLine({
    required this.uid,
    required this.product,
    required this.unitPrice,
    required this.qty,
    this.size,
    this.milk,
    this.ice,
    this.sugar,
    this.extraShot = false,
    this.note,
  });

  final int uid;
  final Product product;
  final int unitPrice;
  final int qty;
  final String? size;
  final String? milk;
  final String? ice;
  final String? sugar;
  final bool extraShot;
  final String? note;

  int get lineTotal => unitPrice * qty;

  String get detail {
    if (product.kind == ProductKind.merch) return product.description;
    final parts = <String>[
      if (size != null) size!,
      if (milk != null) milk!,
      if (ice != null) (ice == 'Tanpa es' ? 'Tanpa es' : 'Es ${ice!.toLowerCase()}'),
      if (sugar != null) 'Gula ${sugar!.toLowerCase()}',
      if (extraShot) '+ shot',
    ];
    return parts.join(' · ');
  }

  CartLine copyWith({int? qty}) => CartLine(
        uid: uid,
        product: product,
        unitPrice: unitPrice,
        qty: qty ?? this.qty,
        size: size,
        milk: milk,
        ice: ice,
        sugar: sugar,
        extraShot: extraShot,
        note: note,
      );

  Map<String, dynamic> toOrderItem() => {
        'product_id': product.id,
        'name_snapshot': product.name,
        'size': size,
        'milk': milk,
        'ice': ice,
        'sugar': sugar,
        'extra_shot': extraShot,
        'note': note,
        'unit_price': unitPrice,
        'qty': qty,
        'line_total': lineTotal,
      };
}
