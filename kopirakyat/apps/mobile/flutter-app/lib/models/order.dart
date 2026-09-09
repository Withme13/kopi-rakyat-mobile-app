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

  AppOrder copyWith({int? stage}) => AppOrder(
        id: id,
        orderNo: orderNo,
        fulfilmentMode: fulfilmentMode,
        tableNumber: tableNumber,
        paymentMethod: paymentMethod,
        total: total,
        status: status,
        stage: stage ?? this.stage,
        pickupCode: pickupCode,
        storeName: storeName,
        items: items,
      );
}
