class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.stampsCost,
  });

  final String id;
  final String name;
  final int stampsCost;

  factory Reward.fromMap(Map<String, dynamic> map) => Reward(
        id: map['id'] as String,
        name: map['name'] as String,
        stampsCost: map['stamps_cost'] as int,
      );
}
