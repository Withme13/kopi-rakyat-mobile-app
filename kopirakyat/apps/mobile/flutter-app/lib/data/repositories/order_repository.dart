import '../../models/address.dart';
import '../../models/cart_line.dart';
import '../../models/fulfilment_mode.dart';
import '../../models/order.dart';
import '../../services/pos_api_service.dart';
import 'payment_gateway.dart';

/// Places orders straight through the POS's `mobileOrdersApi` — there is no
/// `place_order` RPC or `orders`/`order_items` table on the POS's Supabase
/// project, so order data lives only in-memory here for the session
/// (enough to drive the tracking screen's stage simulation) rather than
/// being queried back from Supabase.
class OrderRepository {
  OrderRepository(this._paymentGateway, this._posApiService);

  final PaymentGateway _paymentGateway;
  final PosApiService _posApiService;

  final Map<String, AppOrder> _orders = {};
  AppOrder? _last;
  int _seq = 0;

  AppOrder? get lastOrder => _last;

  Future<AppOrder> placeOrder({
    required String storeId,
    required String storeName,
    required FulfilmentMode fulfilmentMode,
    String? tableNumber,
    String? addressId,
    Address? deliveryAddress,
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

    _seq += 1;
    final externalOrderId = 'app-${DateTime.now().millisecondsSinceEpoch}-$_seq';

    final Map<String, dynamic> posOrder;
    try {
      posOrder = await _posApiService.sendOrder(
        externalOrderId: externalOrderId,
        tableName: tableNumber,
        note: deliveryAddress != null ? 'Kirim ke: ${deliveryAddress.formattedAddress}' : null,
        storeId: storeId,
        fulfilmentMode: fulfilmentMode.db,
        paymentMethod: paymentMethod,
        voucherCode: voucherCode,
        discount: discount,
        deliveryFee: deliveryFee,
        items: lines
            .map((line) => PosOrderItem(
                  menuItemId: line.product.id,
                  qty: line.qty,
                  note: line.note,
                  modifiers: [
                    if (line.size != null) line.size!,
                    if (line.milk != null) line.milk!,
                    if (line.ice != null) line.ice!,
                    if (line.sugar != null) line.sugar!,
                    if (line.extraShot) 'Extra shot',
                  ],
                ))
            .toList(),
      );
    } catch (e) {
      throw StateError('Order dibuat di app, tapi gagal dikirim ke POS: $e');
    }

    final orderNo = posOrder['orderNumber'] as String? ?? externalOrderId;
    final order = AppOrder(
      id: posOrder['id'] as String? ?? externalOrderId,
      orderNo: orderNo,
      fulfilmentMode: fulfilmentMode,
      tableNumber: tableNumber,
      paymentMethod: paymentMethod,
      total: (posOrder['total'] as num?)?.toInt() ?? total,
      status: posOrder['status'] as String? ?? 'new',
      stage: 0,
      pickupCode: orderNo.split('-').last,
      storeName: storeName,
      items: lines
          .map((l) => OrderItemView(nameSnapshot: l.product.name, qty: l.qty, lineTotal: l.lineTotal))
          .toList(),
    );

    _orders[order.id] = order;
    _last = order;
    return order;
  }

  Future<AppOrder> fetchOrder(String orderId) async {
    final order = _orders[orderId];
    if (order == null) {
      throw StateError('Order tidak ditemukan');
    }
    return order;
  }

  Future<AppOrder> advanceStage(String orderId) async {
    final current = _orders[orderId];
    if (current == null) {
      throw StateError('Order tidak ditemukan');
    }
    final next = current.copyWith(stage: (current.stage + 1).clamp(0, 3));
    _orders[orderId] = next;
    if (_last?.id == orderId) _last = next;
    return next;
  }
}
