import 'fulfilment_mode.dart';

class OrderItemView {
  const OrderItemView({
    required this.nameSnapshot,
    required this.qty,
    required this.lineTotal,
  });

  final String nameSnapshot;
  final int qty;
  final int lineTotal;

  factory OrderItemView.fromMap(Map<String, dynamic> map) => OrderItemView(
        nameSnapshot: map['name_snapshot'] as String,
        qty: map['qty'] as int,
        lineTotal: map['line_total'] as int,
      );
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.orderNo,
    required this.fulfilmentMode,
    required this.tableNumber,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.stage,
    required this.pickupCode,
    required this.storeName,
    required this.items,
  });

  final String id;
  final String orderNo;
  final FulfilmentMode fulfilmentMode;
  final String? tableNumber;
  final String paymentMethod;
  final int total;
  final String status;
  final int stage;
  final String? pickupCode;
  final String storeName;
  final List<OrderItemView> items;

  factory AppOrder.fromMap(Map<String, dynamic> map) => AppOrder(
        id: map['id'] as String,
        orderNo: map['order_no'] as String,
        fulfilmentMode: FulfilmentMode.fromDb(map['fulfilment_mode'] as String),
        tableNumber: map['table_number'] as String?,
        paymentMethod: map['payment_method'] as String,
        total: map['total'] as int,
        status: map['status'] as String,
        stage: map['stage'] as int,
        pickupCode: map['pickup_code'] as String?,
        storeName: (map['stores']?['name'] as String?) ?? '',
        items: ((map['order_items'] as List?) ?? [])
            .map((e) => OrderItemView.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}
