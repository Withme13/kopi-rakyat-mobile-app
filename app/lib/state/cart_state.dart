import '../models/cart_line.dart';
import '../models/fulfilment_mode.dart';
import '../models/voucher.dart';

class CartState {
  const CartState({
    this.lines = const [],
    this.fulfilmentMode = FulfilmentMode.pickup,
    this.storeKey = 'Kemang',
    this.table,
    this.paymentMethod = 'QRIS',
    this.when = 'Segera',
    this.promoInput = '',
    this.appliedVoucher,
    this.promoMessage = 'Punya kode? Coba KOPIRAKYAT.',
  });

  final List<CartLine> lines;
  final FulfilmentMode fulfilmentMode;
  final String storeKey;
  final String? table;
  final String paymentMethod;
  final String when;
  final String promoInput;
  final Voucher? appliedVoucher;
  final String promoMessage;

  int get cartCount => lines.fold(0, (a, l) => a + l.qty);
  int get subtotal => lines.fold(0, (a, l) => a + l.lineTotal);
  int get discount => appliedVoucher == null ? 0 : appliedVoucher!.discountFor(subtotal);
  int get deliveryFee => fulfilmentMode == FulfilmentMode.delivery ? 12000 : 0;
  int get total => (subtotal - discount).clamp(0, 1 << 62) + deliveryFee;
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({
    List<CartLine>? lines,
    FulfilmentMode? fulfilmentMode,
    String? storeKey,
    Object? table = _unset,
    String? paymentMethod,
    String? when,
    String? promoInput,
    Object? appliedVoucher = _unset,
    String? promoMessage,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      fulfilmentMode: fulfilmentMode ?? this.fulfilmentMode,
      storeKey: storeKey ?? this.storeKey,
      table: identical(table, _unset) ? this.table : table as String?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      when: when ?? this.when,
      promoInput: promoInput ?? this.promoInput,
      appliedVoucher: identical(appliedVoucher, _unset) ? this.appliedVoucher : appliedVoucher as Voucher?,
      promoMessage: promoMessage ?? this.promoMessage,
    );
  }
}

const _unset = Object();
