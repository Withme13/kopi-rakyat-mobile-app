import 'dart:convert';
import 'package:http/http.dart' as http;

/// One line item as expected by the POS's `createOrderSchema`
/// (see `recipe-till-joy/src/lib/mobileOrdersApi.ts`): `menuItemId` must be
/// a real UUID from that Supabase project's `menus` table.
class PosOrderItem {
  PosOrderItem({
    required this.menuItemId,
    required this.qty,
    this.note,
    this.modifiers = const [],
  });

  final String menuItemId;
  final int qty;
  final String? note;
  final List<String> modifiers;

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'qty': qty,
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
        'modifiers': modifiers,
      };
}

class PosApiService {
  PosApiService({
    required this.baseUrl,
    required this.apiKey,
  });

  final String baseUrl;
  final String apiKey;

  /// Mirrors `createOrderSchema` in `mobileOrdersApi.ts`. The POS recomputes
  /// prices/subtotal/total itself from the current menu snapshot, so those
  /// aren't sent — only `discount` is accepted from the client.
  Future<void> sendOrder({
    required String externalOrderId,
    required List<PosOrderItem> items,
    String? customerName,
    String? customerPhone,
    String? tableName,
    String? note,
    String? storeId,
    String? fulfilmentMode,
    String? paymentMethod,
    String? voucherCode,
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
        'externalOrderId': externalOrderId,
        if (customerName != null && customerName.trim().isNotEmpty)
          'customerName': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customerPhone': customerPhone.trim(),
        if (tableName != null && tableName.trim().isNotEmpty) 'tableName': tableName.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (storeId != null && storeId.trim().isNotEmpty) 'storeId': storeId.trim(),
        if (fulfilmentMode != null && fulfilmentMode.trim().isNotEmpty)
          'fulfilmentMode': fulfilmentMode.trim(),
        if (paymentMethod != null && paymentMethod.trim().isNotEmpty)
          'paymentMethod': paymentMethod.trim(),
        if (voucherCode != null && voucherCode.trim().isNotEmpty) 'voucherCode': voucherCode.trim(),
        if (discount > 0) 'discount': discount,
        if (deliveryFee > 0) 'deliveryFee': deliveryFee,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal kirim order ke POS: ${response.statusCode} - ${response.body}');
    }
  }
}
