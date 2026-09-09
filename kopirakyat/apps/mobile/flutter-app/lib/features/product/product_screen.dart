import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/option.dart';
import '../../models/product.dart';
import '../../state/cart_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/segmented_option_row.dart';

const _extraShotPrice = 8000;

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String _size = 'M';
  String _milk = 'Fresh';
  String _ice = 'Normal';
  String _sugar = 'Normal';
  bool _shot = false;
  String _note = '';
  int _qty = 1;

  int _unitPrice(Product p, List<OptionGroup> groups) {
    final sizeDelta = groups.firstWhereOrNull((g) => g.key == 'size')?.valueFor(_size).priceDelta ?? 0;
    final milkDelta = groups.firstWhereOrNull((g) => g.key == 'milk')?.valueFor(_milk).priceDelta ?? 0;
    return p.basePrice + sizeDelta + milkDelta + (_shot ? _extraShotPrice : 0);
  }

  @override
  Widget build(BuildContext context) {
    final drinksAsync = ref.watch(drinksProvider);
    final merchAsync = ref.watch(merchProvider);
    final groupsAsync = ref.watch(optionGroupsProvider);

    if (!drinksAsync.hasValue || !merchAsync.hasValue || !groupsAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = [...drinksAsync.value!, ...merchAsync.value!].firstWhereOrNull((p) => p.slug == widget.slug);
    if (product == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Produk tidak ditemukan')));
    }
    final isMerch = product.kind == ProductKind.merch;
    final groups = groupsAsync.value!;
    final unit = isMerch ? product.basePrice : _unitPrice(product, groups);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(children: [
                          SizedBox(
                            height: 230,
                            width: double.infinity,
                            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const PhotoSlot(radius: 0),
                                  )
                                : const PhotoSlot(radius: 0),
                          ),
                          Positioned(top: 14, left: 14, child: CircleIconButton(icon: Icons.arrow_back, onTap: () => context.pop())),
                        ]),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
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
                                        Text((product.categoryKey.isEmpty ? 'Merch' : product.categoryKey).toUpperCase(),
                                            style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                                        const SizedBox(height: 5),
                                        Text(product.name,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 27, letterSpacing: -0.025, height: 1.08)),
                                      ],
                                    ),
                                  ),
                                  Text(formatRupiah(product.basePrice), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('${product.description} · ${product.origin}',
                                  style: TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.inkAlpha(0.65))),
                              const Divider(height: 37, color: AppColors.divider),
                              if (!isMerch) ...[
                                for (final group in groups) ...[
                                  _OptionBlock(
                                    group: group,
                                    selected: switch (group.key) {
                                      'size' => _size,
                                      'milk' => _milk,
                                      'ice' => _ice,
                                      'sugar' => _sugar,
                                      _ => '',
                                    },
                                    onPick: (key) => setState(() {
                                      if (group.key == 'size') {
                                        _size = key;
                                      } else if (group.key == 'milk') {
                                        _milk = key;
                                      } else if (group.key == 'ice') {
                                        _ice = key;
                                      } else if (group.key == 'sugar') {
                                        _sugar = key;
                                      }
                                    }),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                _ExtraShot(shot: _shot, onToggle: () => setState(() => _shot = !_shot)),
                                const SizedBox(height: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('CATATAN BARISTA',
                                        style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                                    const SizedBox(height: 8),
                                    TextField(
                                      onChanged: (v) => _note = v,
                                      decoration: const InputDecoration(hintText: 'Contoh: susu terpisah'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.chrome, border: Border(top: BorderSide(color: AppColors.divider))),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: AppColors.ink, width: 1.5), borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              _QtyButton(icon: Icons.remove, onTap: () => setState(() => _qty = (_qty - 1).clamp(1, 99))),
                              SizedBox(width: 36, child: Center(child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                              _QtyButton(icon: Icons.add, onTap: () => setState(() => _qty++)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BrandButton(
                            label: 'Tambah',
                            height: 48,
                            trailing: Text(formatRupiah(unit * _qty), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                            onTap: () {
                              ref.read(cartControllerProvider.notifier).addProduct(
                                    product,
                                    size: isMerch ? null : _size,
                                    milk: isMerch ? null : _milk,
                                    ice: isMerch ? null : _ice,
                                    sugar: isMerch ? null : _sugar,
                                    extraShot: !isMerch && _shot,
                                    note: _note.isEmpty ? null : _note,
                                    qty: _qty,
                                    unitPrice: unit,
                                  );
                              // Capture the router before popping — `context` here belongs to
                              // this (about-to-be-disposed) route, so it can't be used for
                              // navigation once the SnackBar's "Lihat keranjang" is tapped later.
                              final router = GoRouter.of(context);
                              context.pop();
                              showToast(context, '$_qty× ${product.name} masuk keranjang', onViewCart: () => router.push('/cart'));
                            },
                          ),
                        ),
                      ],
                    ),
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

class _OptionBlock extends StatelessWidget {
  const _OptionBlock({required this.group, required this.selected, required this.onPick});
  final OptionGroup group;
  final String selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.label.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
        const SizedBox(height: 8),
        SegmentedOptionRow(
          options: [
            for (final v in group.values)
              SegmentedOption(label: v.key, sub: v.subLabel, selected: selected == v.key, onTap: () => onPick(v.key)),
          ],
        ),
      ],
    );
  }
}

class _ExtraShot extends StatelessWidget {
  const _ExtraShot({required this.shot, required this.onToggle});
  final bool shot;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAMBAHAN', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
        const SizedBox(height: 8),
        Material(
          color: shot ? AppColors.hover : AppColors.muted,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(border: Border.all(color: shot ? AppColors.brand : AppColors.inkAlpha(0.3)), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.ink, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                      color: shot ? AppColors.brand : Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Extra shot espresso', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('+ ${formatRupiah(_extraShotPrice)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(width: 42, height: 48, child: Icon(icon, size: 18)),
    );
  }
}
