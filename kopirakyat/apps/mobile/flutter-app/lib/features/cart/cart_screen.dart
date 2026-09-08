import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/cart_line.dart';
import '../../state/cart_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              child: Row(
                children: [
                  CircleIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                  const SizedBox(width: 10),
                  const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.02)),
                  const Spacer(),
                  Text('${cart.cartCount} item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkAlpha(0.55))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final line in cart.lines) _CartLineTile(line: line, controller: controller),
                  if (cart.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keranjang masih kosong', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                          const SizedBox(height: 6),
                          Text('Tambahkan kopi dari menu untuk lanjut ke pembayaran.',
                              style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.inkAlpha(0.6))),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 180,
                            child: BrandButton(label: 'Buka menu →', height: 46, onTap: () => context.go('/menu')),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KODE PROMO', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                textCapitalization: TextCapitalization.characters,
                                onChanged: controller.setPromoInput,
                                decoration: const InputDecoration(hintText: 'KOPIRAKYAT'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlineButton(
                              label: 'Pakai',
                              height: 48,
                              onTap: () async {
                                final voucher = await ref.read(voucherRepositoryProvider).findByCode(cart.promoInput.trim());
                                if (voucher != null && voucher.scope == 'cart') {
                                  controller.applyVoucherResult(voucher: voucher, message: 'Promo aktif — diskon dipakai.');
                                } else {
                                  controller.applyVoucherResult(voucher: null, message: 'Kode tidak dikenal. Demo: KOPIRAKYAT.');
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(cart.promoMessage,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cart.appliedVoucher != null ? AppColors.brand : AppColors.inkAlpha(0.55))),
                        const Divider(height: 33, color: AppColors.divider),
                        _TotalRow(label: 'Subtotal', value: formatRupiah(cart.subtotal)),
                        if (cart.discount > 0)
                          _TotalRow(label: 'Promo ${cart.appliedVoucher?.code ?? ''}', value: '− ${formatRupiah(cart.discount)}', bold: true, color: AppColors.brand),
                        if (cart.deliveryFee > 0) _TotalRow(label: 'Ongkos kirim', value: formatRupiah(cart.deliveryFee)),
                        _TotalRow(label: 'Total', value: formatRupiah(cart.total), big: true),
                      ],
                    ),
                  ),
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
                    label: 'Checkout',
                    trailing: Text(formatRupiah(cart.total), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    enabled: !cart.isEmpty,
                    onTap: () => cart.isEmpty ? showToast(context, 'Keranjang masih kosong') : context.push('/checkout'),
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

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.controller});
  final CartLine line;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text(line.product.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(line.detail, style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.inkAlpha(0.6))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.inkAlpha(0.35))),
                      child: Row(
                        children: [
                          _StepperButton(icon: Icons.remove, onTap: () => controller.decrementLine(line.uid)),
                          SizedBox(width: 30, child: Center(child: Text('${line.qty}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)))),
                          _StepperButton(icon: Icons.add, onTap: () => controller.incrementLine(line.uid)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => controller.removeLine(line.uid),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text('Hapus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brand)),
                      ),
                    ),
                    const Spacer(),
                    Text(formatRupiah(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 16)));
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false, this.big = false, this.color});
  final String label;
  final String value;
  final bool bold;
  final bool big;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: big ? 19 : 13.5,
      fontWeight: bold || big ? FontWeight.w800 : FontWeight.w600,
      color: color ?? AppColors.ink.withValues(alpha: big ? 1 : 0.7),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]),
    );
  }
}
