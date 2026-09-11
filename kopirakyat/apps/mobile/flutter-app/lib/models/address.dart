class Address {
  const Address({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.label = 'Alamat pengiriman',
  });

  final String label;
  final String formattedAddress;
  final double latitude;
  final double longitude;
}
