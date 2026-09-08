/// Abstraction over "charge the customer" so the checkout flow doesn't care
/// whether payment is simulated (today) or a real gateway (Midtrans/Xendit,
/// later) — only `OrderRepository.placeOrder` depends on this.
abstract class PaymentGateway {
  String get providerId;

  Future<PaymentResult> charge({required int amount, required String method});
}

class PaymentResult {
  const PaymentResult({required this.success, this.reference});

  final bool success;
  final String? reference;
}

/// Always succeeds instantly — matches the prototype's "Bayar" flow, which
/// has no real payment step yet.
class SimulatedPaymentGateway implements PaymentGateway {
  @override
  String get providerId => 'simulated';

  @override
  Future<PaymentResult> charge({required int amount, required String method}) async {
    return const PaymentResult(success: true, reference: 'SIMULATED');
  }
}
