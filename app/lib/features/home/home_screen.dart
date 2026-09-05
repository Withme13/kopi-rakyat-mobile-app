import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/fulfilment_mode.dart';
import '../../models/product.dart';
import '../../state/cart_controller.dart';
import '../../state/menu_nav_state.dart';
import '../../state/profile_controller.dart';
import '../../theme/batik_pattern.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final isGuest = ref.watch(isGuestProvider);
    final isSignedIn = ref.watch(isSignedInProvider);
    final cart = ref.watch(cartControllerProvider);
    final storesAsync = ref.watch(storesProvider);
    final drinksAsync = ref.watch(drinksProvider);
    final vouchersAsync = ref.watch(vouchersProvider);
    final featuredDrink = drinksAsync.valueOrNull?.firstOrNull;

    final userName = profileAsync.value?.fullName ?? (isGuest ? 'Fais' : 'Rangga');

    return BatikBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 26),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat pagi,',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkAlpha(0.6))),
                      const SizedBox(height: 2),
                      Text('Hai, $userName',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.02)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.panel,
                      child: isSignedIn
                          ? Text(profileAsync.value?.initials ?? 'RS',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))
                          : const Icon(Icons.person_outline, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: storesAsync.when(
                data: (stores) {
                  final store = stores.where((s) => s.key == cart.storeKey).firstOrNull ?? stores.firstOrNull;
                  return CardSurface(
                    onTap: () => context.push('/locator'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Kopi Rakyat ${store?.key ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                                  ),
                                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.inkAlpha(0.5)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(store?.address ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11.5, color: AppColors.inkAlpha(0.55))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 60),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFE4E3E0), borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Row(
                  children: [
                    for (final mode in FulfilmentMode.values)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(cartControllerProvider.notifier).setFulfilmentMode(mode);
                            if (mode == FulfilmentMode.dineIn && cart.table == null) {
                              context.push('/qr');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                            decoration: BoxDecoration(
                              color: cart.fulfilmentMode == mode ? AppColors.brand : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              mode.short,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: cart.fulfilmentMode == mode ? Colors.white : AppColors.inkAlpha(0.55),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () {
                  ref.read(menuInitialTabProvider.notifier).state = 'Coffee';
                  context.go('/menu');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 162,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: AppColors.panel,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.pill)),
                                  child: const Text('PROMO SPESIAL',
                                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                                ),
                                const SizedBox(height: 12),
                                const Text('Buy 1 Get 1\nFREE',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21, height: 1.1, letterSpacing: -0.02)),
                                const SizedBox(height: 7),
                                Text('Setiap pembelian varian Signature Latte',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11.5, height: 1.3)),
                              ],
                            ),
                          ),
                        ),
                        Expanded(flex: 4, child: RemotePhoto(imageUrl: featuredDrink?.imageUrl, radius: 0)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: SectionHeader(title: 'Spesial Hari Ini', onSeeAll: () => context.go('/menu')),
            ),
            SizedBox(
              height: 196,
              child: drinksAsync.when(
                data: (drinks) {
                  if (drinks.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada produk minuman. Tambahkan data di tabel products.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.inkAlpha(0.55)),
                      ),
                    );
                  }
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final drink in drinks.take(8)) ...[
                        _SpecialCard(product: drink),
                        const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat menu: $e')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Diskon & Cashback', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.015)),
                  const SizedBox(height: 12),
                  vouchersAsync.when(
                    data: (vouchers) {
                      final shown = vouchers.where((v) => v.code != 'KOPIRAKYAT').take(2).toList();
                      return Row(
                        children: [
                          for (var i = 0; i < shown.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: CardSurface(
                                onTap: () => showToast(context, 'Kode ${shown[i].code} disimpan — pakai di keranjang'),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                                      child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 17),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(shown[i].title,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                                          const SizedBox(height: 2),
                                          Text('Kode: ${shown[i].code}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 11, color: AppColors.inkAlpha(0.55))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 60),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: BrandButton(
                leading: const Icon(Icons.login, color: Colors.white, size: 19),
                label: isSignedIn ? 'Lihat Merch & Voucher' : 'Daftar atau Masuk',
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                onTap: () => isSignedIn ? context.go('/merch') : context.push('/onboarding'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialCard extends StatelessWidget {
  const _SpecialCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.slug}'),
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 112, width: 168, child: RemotePhoto(imageUrl: product.imageUrl)),
            const SizedBox(height: 9),
            Text(product.name, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(height: 3),
            Text(product.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: AppColors.inkAlpha(0.55))),
            const SizedBox(height: 8),
            PriceTag(text: formatRupiah(product.basePrice)),
          ],
        ),
      ),
    );
  }
}
