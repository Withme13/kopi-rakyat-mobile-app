import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/catalog_meta.dart';
import '../../data/providers.dart';
import '../../models/fulfilment_mode.dart';
import '../../models/product.dart';
import '../../state/cart_controller.dart';
import '../../state/menu_nav_state.dart';
import '../../theme/batik_pattern.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _tab = 'Promo & Combo';
  bool _searchOpen = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preset = ref.read(menuInitialTabProvider);
      if (preset != null) {
        setState(() => _tab = preset);
        ref.read(menuInitialTabProvider.notifier).state = null;
      }
    });
  }

  void _addDefault(Product p) {
    ref.read(cartControllerProvider.notifier).addProduct(p, size: 'M', milk: 'Fresh', ice: 'Normal', sugar: 'Normal', unitPrice: p.basePrice);
    showToast(context, '${p.name} masuk keranjang', onViewCart: () => context.push('/cart'));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final drinksAsync = ref.watch(drinksProvider);
    final storesAsync = ref.watch(storesProvider);
    final searching = _searchOpen && _query.isNotEmpty;

    final destLabel = cart.fulfilmentMode == FulfilmentMode.delivery
        ? 'Kirim ke'
        : (cart.fulfilmentMode == FulfilmentMode.dineIn ? 'Meja' : 'Ambil di');
    final storeName = storesAsync.value?.where((s) => s.key == cart.storeKey).firstOrNull?.name ?? '';
    final dest = cart.fulfilmentMode == FulfilmentMode.delivery
        ? 'Graha Sudirman, Bendungan Hilir'
        : (cart.fulfilmentMode == FulfilmentMode.dineIn
            ? (cart.table != null ? 'Meja ${cart.table} · ${cart.storeKey}' : 'Pilih meja dulu')
            : storeName.replaceFirst('Kopi Rakyat ', ''));

    return BatikBackground(
      child: SafeArea(
        bottom: false,
        child: drinksAsync.when(
          data: (drinks) => Column(
            children: [
              _Header(
                destLabel: destLabel,
                dest: dest,
                tab: _tab,
                searchOpen: _searchOpen,
                query: _query,
                onDestTap: () => context.push('/locator'),
                onSearchToggle: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) _query = '';
                }),
                onNotif: () => showToast(context, 'Belum ada notifikasi baru'),
                onQueryChanged: (v) => setState(() => _query = v),
                onTabPick: (t) => setState(() => _tab = t),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (searching)
                      _SearchResults(query: _query, drinks: drinks, onAdd: _addDefault)
                    else ...[
                      if (_tab == 'Promo & Combo') _PromoCombo(drinks: drinks),
                      if (_tab == 'Promo & Combo' || _tab == 'Baru!') _BaruHero(drinks: drinks),
                      for (final entry in menuGroups.entries)
                        if (_tab == 'Promo & Combo' || _tab == entry.key)
                          _MenuSection(
                            title: entry.key,
                            items: drinks.where((d) => entry.value.contains(d.categoryKey)).toList(),
                            onTabAll: () => setState(() => _tab = entry.key),
                            onAdd: _addDefault,
                          ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat menu: $e')),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.destLabel,
    required this.dest,
    required this.tab,
    required this.searchOpen,
    required this.query,
    required this.onDestTap,
    required this.onSearchToggle,
    required this.onNotif,
    required this.onQueryChanged,
    required this.onTabPick,
  });

  final String destLabel;
  final String dest;
  final String tab;
  final bool searchOpen;
  final String query;
  final VoidCallback onDestTap;
  final VoidCallback onSearchToggle;
  final VoidCallback onNotif;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onTabPick;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.chrome, border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDestTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(destLabel.toUpperCase(),
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.inkAlpha(0.55))),
                          const SizedBox(width: 5),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.inkAlpha(0.45)),
                        ]),
                        const SizedBox(height: 2),
                        Text(dest, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      ],
                    ),
                  ),
                ),
                IconButton(onPressed: onSearchToggle, icon: Icon(Icons.search, color: searchOpen ? AppColors.brand : AppColors.inkAlpha(0.7))),
                IconButton(onPressed: onNotif, icon: Icon(Icons.notifications_outlined, color: AppColors.inkAlpha(0.7))),
              ],
            ),
          ),
          if (searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.ink, width: 1.5), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  autofocus: true,
                  onChanged: onQueryChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari kopi, snack…',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final t in menuTabs)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () => onTabPick(t),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 10, top: 2),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: tab == t ? AppColors.brand : Colors.transparent))),
                        child: Text(t, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tab == t ? AppColors.brand : AppColors.inkAlpha(0.55))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query, required this.drinks, required this.onAdd});
  final String query;
  final List<Product> drinks;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final results = drinks.where((m) => '${m.name} ${m.description} ${m.categoryKey}'.toLowerCase().contains(q)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            results.isEmpty ? 'Tidak ada item yang cocok. Coba kata lain.' : '${results.length} item · harga sudah termasuk pajak',
            style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.55)),
          ),
        ),
        for (final m in results)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/product/${m.slug}'),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: Text(m.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21)),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/product/${m.slug}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                        const SizedBox(height: 2),
                        Text(m.description, style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.6))),
                        const SizedBox(height: 5),
                        Text(formatRupiah(m.basePrice), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ),
                _AddButton(onTap: () => onAdd(m)),
              ],
            ),
          ),
      ],
    );
  }
}

class _PromoCombo extends StatelessWidget {
  const _PromoCombo({required this.drinks});
  final List<Product> drinks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 12), child: SectionHeader(title: 'Promo & Combo')),
          SizedBox(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final c in promoCombo) ...[
                  _PromoTile(promo: c, product: drinks.where((d) => d.slug == c.productSlug).firstOrNull),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({required this.promo, required this.product});
  final PromoCard promo;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: product == null ? null : () => context.push('/product/${product!.slug}'),
      child: SizedBox(
        width: 152,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              SizedBox(height: 118, width: 152, child: RemotePhoto(imageUrl: product?.imageUrl)),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Text('PROMO DELIVERY', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ]),
            const SizedBox(height: 9),
            Text(promo.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(height: 7),
            PriceTag(text: promo.priceLabel),
          ],
        ),
      ),
    );
  }
}

class _BaruHero extends StatelessWidget {
  const _BaruHero({required this.drinks});
  final List<Product> drinks;

  @override
  Widget build(BuildContext context) {
    final product = drinks.where((d) => d.slug == baruItem.productSlug).firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: product == null ? null : () => context.push('/product/${product.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Baru!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.015)),
            const SizedBox(height: 12),
            Stack(children: [
              SizedBox(height: 186, width: double.infinity, child: RemotePhoto(imageUrl: product?.imageUrl)),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Text('NEW', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ]),
            const SizedBox(height: 11),
            Text(product?.name ?? baruItem.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: -0.01)),
            const SizedBox(height: 4),
            Text(product == null ? baruItem.priceLabel : formatRupiah(product.basePrice),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.inkAlpha(0.75))),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items, required this.onTabAll, required this.onAdd});
  final String title;
  final List<Product> items;
  final VoidCallback onTabAll;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onSeeAll: onTabAll),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
            children: [for (final p in items) _MenuGridItem(product: p, onAdd: () => onAdd(p))],
          ),
        ],
      ),
    );
  }
}

class _MenuGridItem extends StatelessWidget {
  const _MenuGridItem({required this.product, required this.onAdd});
  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final badgeText = product.badge ?? (categoryLabels[product.categoryKey] ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/product/${product.slug}'),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Stack(children: [
              RemotePhoto(imageUrl: product.imageUrl),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.badge != null ? AppColors.brand : AppColors.panel,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(badgeText.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/product/${product.slug}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(formatRupiah(product.basePrice), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.inkAlpha(0.75))),
                  ],
                ),
              ),
            ),
            _AddButton(onTap: onAdd, size: 36),
          ],
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, this.size = 44});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Icon(Icons.add, color: Colors.white, size: size * 0.45)),
      ),
    );
  }
}
