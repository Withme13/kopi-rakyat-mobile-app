class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.tier,
    required this.points,
    required this.stamps,
    required this.biometricEnabled,
  });

  final String id;
  final String fullName;
  final String tier;
  final int points;
  final int stamps;
  final bool biometricEnabled;

  String get initials =>
      fullName.trim().split(RegExp(r'\s+')).map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

  Profile copyWith({int? stamps, int? points, bool? biometricEnabled}) => Profile(
        id: id,
        fullName: fullName,
        tier: tier,
        points: points ?? this.points,
        stamps: stamps ?? this.stamps,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      );

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        fullName: map['full_name'] as String? ?? 'Rangga',
        tier: map['tier'] as String? ?? 'Silver',
        points: map['points'] as int? ?? 0,
        stamps: map['stamps'] as int? ?? 0,
        biometricEnabled: map['biometric_enabled'] as bool? ?? false,
      );
}
