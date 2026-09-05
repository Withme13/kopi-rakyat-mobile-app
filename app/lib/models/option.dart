class OptionValue {
  const OptionValue({
    required this.key,
    required this.subLabel,
    required this.priceDelta,
  });

  final String key;
  final String subLabel;
  final int priceDelta;

  factory OptionValue.fromMap(Map<String, dynamic> map) => OptionValue(
        key: map['key'] as String,
        subLabel: map['sub_label'] as String? ?? '',
        priceDelta: map['price_delta'] as int? ?? 0,
      );
}

class OptionGroup {
  const OptionGroup({
    required this.key,
    required this.label,
    required this.values,
  });

  final String key; // size | milk | ice | sugar
  final String label;
  final List<OptionValue> values;

  OptionValue valueFor(String key) =>
      values.firstWhere((v) => v.key == key, orElse: () => values.first);
}
