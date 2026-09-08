import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/cart_line.dart';
import '../../models/fulfilment_mode.dart';
import '../../models/order.dart';
import '../../services/pos_api_service.dart';
import 'payment_gateway.dart';

class OrderRepository {
  OrderRepository(this._client, this._paymentGateway, this._posApiService);

  final SupabaseClient _client;
  final PaymentGateway _paymentGateway;
  final PosApiService _posApiService;

  /// Charges via [PaymentGateway] then atomically places the order through
  /// the `place_order` RPC (see `supabase/migrations`), which also grants
  /// the loyalty stamp. Throws if payment fails or the user has no session.
  Future<AppOrder> placeOrder({
    required String storeId,
    required FulfilmentMode fulfilmentMode,
    String? tableNumber,
    String? addressId,
    DateTime? scheduledFor,
    required String paymentMethod,
    required List<CartLine> lines,
    required int subtotal,
    required int discount,
    required int deliveryFee,
    required int total,
    String? voucherCode,
  }) async {
    final payment = await _paymentGateway.charge(amount: total, method: paymentMethod);
    if (!payment.success) {
      throw StateError('Pembayaran gagal, coba lagi.');
    }

    final row = await _client.rpc('place_order', params: {
      'p_store_id': storeId,
      'p_fulfilment_mode': fulfilmentMode.db,
      'p_table_number': tableNumber,
      'p_address_id': addressId,
      'p_scheduled_for': scheduledFor?.toIso8601String(),
      'p_payment_method': paymentMethod,
      'p_payment_provider': _paymentGateway.providerId,
      'p_subtotal': subtotal,
      'p_discount': discount,
      'p_delivery_fee': deliveryFee,
      'p_total': total,
      'p_voucher_code': voucherCode,
      'p_items': lines.map((l) => l.toOrderItem()).toList(),
    });

    final orderId = row['id'] as String;

    try {
      await _posApiService.sendOrder(
        orderId: orderId,
        items: lines
            .map((line) => {
                  'product_id': line.product.id,
                  'product_name': line.product.name,
                  'qty': line.qty,
                  'price': line.unitPrice,
                  'notes': line.note ?? '',
                })
            .toList(),
        total: total,
        paymentMethod: paymentMethod,
        fulfilmentMode: fulfilmentMode.db,
        storeId: storeId,
        tableNumber: tableNumber,
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
      );
    } catch (e) {
      throw StateError('Order dibuat di app, tapi gagal dikirim ke POS: $e');
    }

    return fetchOrder(orderId);
  }

  Future<AppOrder> fetchOrder(String orderId) async {
    final row = await _client
        .from('orders')
        .select('*, stores(name), order_items(*)')
        .eq('id', orderId)
        .single();
    return AppOrder.fromMap(row);
  }

  Future<AppOrder> advanceStage(String orderId) async {
    final row = await _client.rpc('advance_order_stage', params: {'p_order_id': orderId});
    return fetchOrder((row as Map<String, dynamic>)['id'] as String);
  }
}
