import 'dart:convert';
import 'package:http/http.dart' as http;

/// Search + reverse geocoding via OpenStreetMap's Nominatim API. It's free
/// and needs no API key, but its usage policy requires a descriptive
/// User-Agent and asks for at most ~1 request/second per client.
class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _headers = {'User-Agent': 'KopiRakyatApp/1.0 (com.kopirakyat.kopi_rakyat_app)'};

  Future<List<GeocodingResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': trimmed,
      'format': 'json',
      'limit': '5',
      'countrycodes': 'id',
    });
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body) as List;
    return decoded
        .map((item) => GeocodingResult(
              displayName: item['display_name'] as String,
              latitude: double.parse(item['lat'] as String),
              longitude: double.parse(item['lon'] as String),
            ))
        .toList();
  }

  Future<String> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
      'lat': '$latitude',
      'lon': '$longitude',
      'format': 'json',
    });
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['display_name'] as String? ?? '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}

class GeocodingResult {
  const GeocodingResult({required this.displayName, required this.latitude, required this.longitude});

  final String displayName;
  final double latitude;
  final double longitude;
}
