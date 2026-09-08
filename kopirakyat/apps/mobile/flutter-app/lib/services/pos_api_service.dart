import 'dart:convert';
import 'package:http/http.dart' as http;

class PosApiService {
  PosApiService({
    required this.baseUrl,
    required this.apiKey,
  });

  final String baseUrl;
  final String apiKey;

  Future<void> sendOrder({
    required String orderId,
    required List<Map<String, dynamic>> items,
    required int total,
    required String paymentMethod,
    required String fulfilmentMode,
    String? storeId,
    String? tableNumber,
    String? customerId,
    int subtotal = 0,
    int discount = 0,
    int deliveryFee = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'source': 'mobile_app',
        'order_id': orderId,
        'customer_id': customerId,
        'store_id': storeId,
        'fulfilment_mode': fulfilmentMode,
        'table_number': tableNumber,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'discount': discount,
        'delivery_fee': deliveryFee,
        'total': total,
        'items': items,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal kirim order ke POS: ${response.statusCode} - ${response.body}');
    }
  }
}
