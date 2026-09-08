import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/reward.dart';
import '../../state/cart_controller.dart';
import '../../state/profile_controller.dart';
import '../../theme/batik_pattern.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    final storesAsync = ref.watch(storesProvider);
    final merchAsync = ref.watch(merchProvider);
    final vouchersAsync = ref.watch(vouchersProvider);
    final rewardsAsync = ref.watch(rewardsProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    final profile = profileAsync.value;
    final stamps = profile?.stamps ?? 6;
    final points = profile?.points ?? 1200;
    final tier = profile?.tier ?? 'Silver';
    final store = storesAsync.value?.where((s) => s.key == cart.storeKey).firstOrNull;

    return BatikBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 26),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.ink),
                  const SizedBox(width: 7),
                  Text(tier, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  const SizedBox(width: 6),
                  Text(stamps >= 8 ? '80%' : '45%', style: TextStyle(fontSize: 13, color: AppColors.inkAlpha(0.55))),
                  const SizedBox(width: 14),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('K', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 7),
                  Text('$points', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  const SizedBox(width: 4),
                  Text('pts', style: TextStyle(fontSize: 13, color: AppColors.inkAlpha(0.55))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CardSurface(
                      onTap: () => context.push('/locator'),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text('Kopi Rakyat ${store?.key ?? ''}',
                                    overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5))),
                            const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.brand),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            Text('Melayani', style: TextStyle(fontSize: 11.5, color: AppColors.inkAlpha(0.5))),
                            const SizedBox(width: 12),
                            const _Dot(color: AppColors.brand),
                            const SizedBox(width: 5),
                            const Text('Delivery', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            const _Dot(color: AppColors.panel),
                            const SizedBox(width: 5),
                            const Text('Pickup', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context.push('/qr'),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(color: AppColors.voucherTint, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.qr_code_2, color: AppColors.brand, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 0), child: SizedBox(height: 170, child: PhotoSlot(radius: 20))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: 0.86,
                children: [
                  _QuickTile(icon: Icons.storefront_outlined, label: 'Merch Store', onTap: () => showToast(context, 'Katalog merch lengkap menyusul')),
                  _QuickTile(
                    icon: Icons.local_shipping_outlined,
                    label: 'Cek Pengiriman',
                    onTap: () async {
                      final userId = ref.read(currentUserProvider)?.id;
                      if (userId == null) return;
                      final rows = await ref.read(supabaseClientProvider).from('orders').select('id').eq('user_id', userId).order('created_at', ascending: false).limit(1);
                      if (rows.isNotEmpty) {
                        if (context.mounted) context.push('/tracking/${rows.first['id']}');
                      } else if (context.mounted) {
                        showToast(context, 'Belum ada pesanan aktif');
                      }
                    },
                  ),
                  _QuickTile(icon: Icons.confirmation_number_outlined, label: 'Voucher Kopi', tag: 'Baru', onTap: () => showToast(context, '3 voucher aktif di akunmu')),
                  _QuickTile(icon: Icons.card_giftcard_outlined, label: 'Kado & Bundling', onTap: () => showToast(context, 'Bundling hadiah menyusul')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: CardSurface(
                onTap: () => showToast(context, 'Poster edisi terbatas — stok Kemang tersisa 12'),
                child: Row(
                  children: [
                    const SizedBox(width: 58, height: 58, child: PhotoSlot(radius: 14)),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dapatkan Poster', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.brand)),
                          SizedBox(height: 2),
                          Text('Menangkan hingga Level 3!', style: TextStyle(fontSize: 12.5, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center,
                      child: const Text('View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.voucherTint, border: Border.all(color: AppColors.brand, width: 1.5), borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.local_cafe, color: AppColors.brand),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(child: Text('Voucher Buy 1 Get 1 SEPUASNYA!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5))),
                    GestureDetector(
                      onTap: () => showToast(context, 'Voucher Buy 1 Get 1 diklaim · aktif 7 hari'),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: const Text('Klaim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Khusus Pengguna Baru', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.015)),
                  const SizedBox(height: 12),
                  vouchersAsync.when(
                    data: (vouchers) {
                      final merchVouchers = vouchers.where((v) => v.scope == 'merch').toList();
                      return Column(
                        children: [
                          for (final v in merchVouchers)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CardSurface(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: AppColors.voucherTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                                                child: const Text('PAKAI DI APP', style: TextStyle(color: AppColors.voucherRed, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(v.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.25)),
                                              const SizedBox(height: 4),
                                              Text(v.note, style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.inkAlpha(0.55))),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(color: AppColors.hover, borderRadius: BorderRadius.circular(14)),
                                          child: Icon(Icons.receipt_long_outlined, color: AppColors.inkAlpha(0.6)),
                                        ),
                                      ],
                                    ),
                                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: _DashedDivider()),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(v.validUntil != null ? 'Berlaku s/d ${v.validUntil!.day}/${v.validUntil!.month}/${v.validUntil!.year}' : '',
                                                  style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.55))),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            final userId = ref.read(currentUserProvider)?.id;
                                            if (userId != null) {
                                              await ref.read(voucherRepositoryProvider).claim(userId, v.id);
                                            }
                                            if (context.mounted) showToast(context, 'Kode ${v.code} disimpan — pakai di keranjang');
                                          },
                                          child: Container(
                                            height: 44,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                                            alignment: Alignment.center,
                                            child: const Text('Pakai Voucher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Merch Kopi Rakyat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.015)),
                    const Spacer(),
                    Text('Dikirim 2–4 hari', style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.5))),
                  ]),
                  const SizedBox(height: 12),
                  merchAsync.when(
                    data: (merch) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.95,
                      children: [
                        for (final m in merch)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AspectRatio(aspectRatio: 1.15, child: PhotoSlot()),
                              const SizedBox(height: 9),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.3)),
                                        const SizedBox(height: 4),
                                        Text(formatRupiah(m.basePrice), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.inkAlpha(0.75))),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller.addProduct(m, unitPrice: m.basePrice);
                                      showToast(context, '${m.name} masuk keranjang', onViewCart: () => context.push('/cart'));
                                    },
                                    child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('TUKAR CANGKIR · $stamps/10', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                    const SizedBox(width: 8),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ]),
                  const SizedBox(height: 12),
                  rewardsAsync.when(
                    data: (rewards) => Column(
                      children: [
                        for (final r in rewards)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RewardRow(
                              reward: r,
                              stamps: stamps,
                              onRedeem: () async {
                                try {
                                  await ref.read(profileControllerProvider.notifier).redeemReward(r.id, r.stampsCost);
                                  if (context.mounted) showToast(context, '${r.name} ditukar — voucher aktif 7 hari');
                                } catch (e) {
                                  if (context.mounted) showToast(context, 'Kurang cangkir untuk menukar reward ini');
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)));
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.label, required this.onTap, this.tag});
  final IconData icon;
  final String label;
  final String? tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CardSurface(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: AppColors.voucherTint, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.brand, size: 19),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.25)),
            ],
          ),
        ),
        if (tag != null)
          Positioned(
            top: -7,
            left: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.pill)),
              alignment: Alignment.center,
              child: Text(tag!.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward, required this.stamps, required this.onRedeem});
  final Reward reward;
  final int stamps;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final ok = stamps >= reward.stampsCost;
    return CardSurface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 3),
                Text('${reward.stampsCost} cangkir', style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.6))),
              ],
            ),
          ),
          GestureDetector(
            onTap: ok ? onRedeem : null,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ok ? AppColors.brand : AppColors.muted,
                border: Border.all(color: ok ? AppColors.brand : AppColors.inkAlpha(0.25)),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(ok ? 'Tukar' : 'Belum cukup', style: TextStyle(color: ok ? Colors.white : AppColors.inkAlpha(0.45), fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedPainter(), size: const Size(double.infinity, 1));
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 12;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
