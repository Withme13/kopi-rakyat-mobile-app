class Store {
  const Store({
    required this.id,
    required this.key,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.isOpen,
    required this.hoursNote,
    required this.mapX,
    required this.mapY,
  });

  final String id;
  final String key;
  final String name;
  final String address;
  final double distanceKm;
  final bool isOpen;
  final String hoursNote;
  final double mapX;
  final double mapY;

  factory Store.fromMap(Map<String, dynamic> map) => Store(
        id: map['id'] as String,
        key: map['key'] as String,
        name: map['name'] as String,
        address: map['address'] as String,
        distanceKm: (map['distance_km'] as num).toDouble(),
        isOpen: map['is_open'] as bool,
        hoursNote: map['hours_note'] as String,
        mapX: (map['map_x'] as num).toDouble(),
        mapY: (map['map_y'] as num).toDouble(),
      );
}
