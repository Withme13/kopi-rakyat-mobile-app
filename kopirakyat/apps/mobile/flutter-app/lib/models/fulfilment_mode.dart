enum FulfilmentMode {
  delivery('delivery', 'Delivery', 'Dikirim'),
  pickup('pickup', 'Pickup', 'Ambil sendiri'),
  dineIn('dine_in', 'Dine In', 'Makan di tempat'),
  preOrder('pre_order', 'Jadwal', 'Jadwalkan');

  const FulfilmentMode(this.db, this.short, this.label);

  final String db;
  final String short;
  final String label;

  static FulfilmentMode fromDb(String value) =>
      FulfilmentMode.values.firstWhere((m) => m.db == value, orElse: () => FulfilmentMode.pickup);
}
