import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/fulfilment_mode.dart';
import '../../state/cart_controller.dart';
import '../../state/profile_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/segmented_option_row.dart';

const _fulfilmentIcons = {
  FulfilmentMode.delivery: Icons.local_shipping_outlined,
  FulfilmentMode.pickup: Icons.shopping_bag_outlined,
  FulfilmentMode.dineIn: Icons.restaurant_outlined,
  FulfilmentMode.preOrder: Icons.schedule_outlined,
};

const _paymentMethods = [
  ('QRIS', 'semua e-wallet'),
  ('GoPay', 'saldo Rp 148.000'),
  ('Kartu debit/kredit', '•••• 4471'),
  ('Tunai di konter', 'bayar saat ambil'),
];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _placing = false;

  Future<void> _pay() async {
    final cart = ref.read(cartControllerProvider);
    final stores = ref.read(storesProvider).value ?? [];
    final store = stores.firstWhereOrNull((s) => s.key == cart.storeKey);
    if (store == null) return;

    setState(() => _placing = true);
    try {
      final order = await ref.read(orderRepositoryProvider).placeOrder(
            storeId: store.id,
            fulfilmentMode: cart.fulfilmentMode,
            tableNumber: cart.table,
            paymentMethod: cart.paymentMethod,
            lines: cart.lines,
            subtotal: cart.subtotal,
            discount: cart.discount,
            deliveryFee: cart.deliveryFee,
            total: cart.total,
            voucherCode: cart.appliedVoucher?.code,
          );
      ref.read(cartControllerProvider.notifier).clearAfterOrder();
      await ref.read(profileControllerProvider.notifier).refresh();
      if (!mounted) return;
      showToast(context, 'Pembayaran berhasil · +1 cangkir');
      context.go('/home');
      context.push('/tracking/${order.id}');
    } catch (e) {
      if (mounted) showToast(context, 'Pembayaran gagal: $e');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    final storesAsync = ref.watch(storesProvider);
    final store = storesAsync.value?.firstWhereOrNull((s) => s.key == cart.storeKey);

    final destInfo = switch (cart.fulfilmentMode) {
      FulfilmentMode.pickup => (
          label: 'Ambil di',
          title: store?.name ?? '',
          sub: '${store?.address ?? ''} · siap ~8 menit',
          cta: 'Ganti toko',
          action: () => context.push('/locator'),
        ),
      FulfilmentMode.dineIn => (
          label: 'Meja',
          title: cart.table != null ? 'Meja ${cart.table}' : 'Belum pilih meja',
          sub: '${store?.name ?? ''} · pesanan diantar ke meja',
          cta: cart.table != null ? 'Ganti meja' : 'Scan QR meja',
          action: () => context.push('/qr'),
        ),
      FulfilmentMode.delivery => (
          label: 'Kirim ke',
          title: 'Rumah · Rangga',
          sub: 'Jl. Bangka II No. 7, Jaksel · 25–35 menit · ongkir Rp 12.000',
          cta: 'Ganti alamat',
          action: () => showToast(context, 'Daftar alamat belum ada di prototype'),
        ),
      FulfilmentMode.preOrder => (
          label: 'Jadwal',
          title: 'Besok, 07.30',
          sub: '${store?.name ?? ''} · kopi diseduh tepat waktu',
          cta: 'Ganti jadwal',
          action: () => showToast(context, 'Pemilih jadwal menyusul'),
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
              child: Row(children: [
                CircleIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                const SizedBox(width: 10),
                const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.02)),
              ]),
            ),
            Row(
              children: [
                for (final mode in FulfilmentMode.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setFulfilmentMode(mode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        color: cart.fulfilmentMode == mode ? AppColors.panel : AppColors.muted,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_fulfilmentIcons[mode], size: 19, color: cart.fulfilmentMode == mode ? Colors.white : AppColors.ink),
                            const SizedBox(height: 3),
                            Text(mode.label,
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: cart.fulfilmentMode == mode ? Colors.white : AppColors.ink)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  Text(destInfo.label.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                  const SizedBox(height: 8),
                  CardSurface(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(destInfo.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(destInfo.sub, style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.inkAlpha(0.6))),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: destInfo.action,
                          child: Text(destInfo.cta,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.brand, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('WAKTU', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                  const SizedBox(height: 8),
                  SegmentedOptionRow(options: [
                    SegmentedOption(label: 'Segera', sub: '~8 menit', selected: cart.when == 'Segera', onTap: () => controller.setWhen('Segera')),
                    SegmentedOption(label: 'Jadwalkan', sub: 'pilih waktu', selected: cart.when == 'Jadwalkan', onTap: () => controller.setWhen('Jadwalkan')),
                  ]),
                  const SizedBox(height: 20),
                  Text('METODE PEMBAYARAN', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          for (var i = 0; i < _paymentMethods.length; i++)
                            _PaymentRow(
                              label: _paymentMethods[i].$1,
                              meta: _paymentMethods[i].$2,
                              selected: cart.paymentMethod == _paymentMethods[i].$1,
                              showDivider: i != _paymentMethods.length - 1,
                              onTap: () => controller.setPaymentMethod(_paymentMethods[i].$1),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 34, color: AppColors.divider),
                  _TotalLine(label: 'Subtotal', value: formatRupiah(cart.subtotal)),
                  if (cart.discount > 0)
                    _TotalLine(label: 'Promo ${cart.appliedVoucher?.code ?? ''}', value: '− ${formatRupiah(cart.discount)}', color: AppColors.brand, bold: true),
                  if (cart.deliveryFee > 0) _TotalLine(label: 'Ongkos kirim', value: formatRupiah(cart.deliveryFee)),
                  _TotalLine(label: 'Total', value: formatRupiah(cart.total), big: true),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.chrome, border: Border(top: BorderSide(color: AppColors.divider))),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: BrandButton(
                    label: 'Bayar${cart.paymentMethod == 'Tunai di konter' ? ' nanti' : ' · ${cart.paymentMethod}'}',
                    trailing: Text(formatRupiah(cart.total), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    enabled: !_placing && !cart.isEmpty,
                    onTap: _pay,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.meta, required this.selected, required this.onTap, required this.showDivider});
  final String label;
  final String meta;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.hover : AppColors.muted,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: showDivider ? AppColors.hairline : Colors.transparent))),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(border: Border.all(color: AppColors.ink, width: 1.5), borderRadius: BorderRadius.circular(9)),
                alignment: Alignment.center,
                child: selected ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle)) : null,
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(meta, style: TextStyle(fontSize: 11.5, color: AppColors.inkAlpha(0.55))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({required this.label, required this.value, this.color, this.big = false, this.bold = false});
  final String label;
  final String value;
  final Color? color;
  final bool big;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: big ? 19 : 13.5,
      fontWeight: big || bold ? FontWeight.w800 : FontWeight.w600,
      color: color ?? AppColors.ink.withValues(alpha: big ? 1 : 0.7),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]),
    );
  }
}
