import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';
import '../models/cart_line.dart';
import '../models/fulfilment_mode.dart';
import '../models/product.dart';
import '../models/voucher.dart';
import 'cart_state.dart';

/// Cart + fulfilment/checkout selections live client-side (like the
/// prototype's in-memory `state.cart`) and are only written to Supabase
/// once, atomically, at checkout — see `OrderRepository.placeOrder`.
class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  int _uid = 1;

  void addProduct(
    Product product, {
    String? size,
    String? milk,
    String? ice,
    String? sugar,
    bool extraShot = false,
    String? note,
    int qty = 1,
    required int unitPrice,
  }) {
    final line = CartLine(
      uid: _uid++,
      product: product,
      unitPrice: unitPrice,
      qty: qty,
      size: size,
      milk: milk,
      ice: ice,
      sugar: sugar,
      extraShot: extraShot,
      note: note,
    );
    state = state.copyWith(lines: [...state.lines, line]);
  }

  void incrementLine(int uid) => _updateLine(uid, (l) => l.copyWith(qty: l.qty + 1));

  void decrementLine(int uid) => _updateLine(uid, (l) => l.copyWith(qty: (l.qty - 1).clamp(1, 1 << 30)));

  void removeLine(int uid) {
    state = state.copyWith(lines: state.lines.where((l) => l.uid != uid).toList());
  }

  void _updateLine(int uid, CartLine Function(CartLine) update) {
    state = state.copyWith(lines: [
      for (final l in state.lines) l.uid == uid ? update(l) : l,
    ]);
  }

  void setFulfilmentMode(FulfilmentMode mode) => state = state.copyWith(fulfilmentMode: mode);
  void setStore(String key) => state = state.copyWith(storeKey: key);
  void setTable(String? table) => state = state.copyWith(table: table);
  void setPaymentMethod(String method) => state = state.copyWith(paymentMethod: method);
  void setWhen(String when) => state = state.copyWith(when: when);
  void setDeliveryAddress(Address address) => state = state.copyWith(deliveryAddress: address);
  void setPromoInput(String value) => state = state.copyWith(promoInput: value.toUpperCase());

  void applyVoucherResult({required Voucher? voucher, required String message}) {
    state = state.copyWith(appliedVoucher: voucher, promoMessage: message);
  }

  /// Clears the cart after a successful checkout (keeps fulfilment/store
  /// selections, matching the prototype's `finishOrder`).
  void clearAfterOrder() {
    state = state.copyWith(
      lines: const [],
      appliedVoucher: null,
      promoInput: '',
      promoMessage: 'Punya kode? Coba KOPIRAKYAT.',
    );
  }

  void reset() {
    _uid = 1;
    state = const CartState();
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
