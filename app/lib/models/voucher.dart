enum DiscountType { percent, fixed }

class Voucher {
  const Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.note,
    required this.discountType,
    required this.discountValue,
    required this.scope,
    this.validUntil,
  });

  final String id;
  final String code;
  final String title;
  final String note;
  final DiscountType discountType;
  final num discountValue;
  final String scope; // cart | merch
  final DateTime? validUntil;

  int discountFor(int subtotal) {
    if (discountType == DiscountType.percent) {
      return (subtotal * discountValue / 100).round();
    }
    return discountValue.round();
  }

  factory Voucher.fromMap(Map<String, dynamic> map) => Voucher(
        id: map['id'] as String,
        code: map['code'] as String,
        title: map['title'] as String,
        note: map['note'] as String? ?? '',
        discountType:
            (map['discount_type'] as String) == 'fixed' ? DiscountType.fixed : DiscountType.percent,
        discountValue: map['discount_value'] as num,
        scope: map['scope'] as String? ?? 'cart',
        validUntil: map['valid_until'] != null ? DateTime.tryParse(map['valid_until'] as String) : null,
      );
}
