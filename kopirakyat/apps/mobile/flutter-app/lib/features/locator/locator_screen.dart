import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/store.dart';
import '../../state/cart_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class LocatorScreen extends ConsumerWidget {
  const LocatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesProvider);
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: storesAsync.when(
          data: (stores) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                child: Row(
                  children: [
                    const Text('Toko', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.02)),
                    const Spacer(),
                    Text('Jakarta Selatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkAlpha(0.55))),
                  ],
                ),
              ),
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 0),
                decoration: const BoxDecoration(
                  color: AppColors.hover,
                  border: Border.symmetric(horizontal: BorderSide(color: AppColors.divider)),
                ),
                child: Stack(
                  children: [
                    CustomPaint(painter: _GridPainter(), size: Size.infinite),
                    for (final store in stores)
                      Positioned(
                        left: store.mapX / 100 * MediaQuery.of(context).size.width - 20,
                        top: store.mapY / 100 * 200 - 34,
                        child: GestureDetector(
                          onTap: () => controller.setStore(store.key),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                color: cart.storeKey == store.key ? AppColors.brand : AppColors.panel,
                                child: Text(store.key, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                              ),
                              Transform.rotate(
                                angle: 0.785398,
                                child: Container(width: 10, height: 10, color: cart.storeKey == store.key ? AppColors.brand : AppColors.panel),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              for (final store in stores) _StoreRow(store: store, selected: cart.storeKey == store.key, onTap: () => controller.setStore(store.key)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat toko: $e')),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store, required this.selected, required this.onTap});
  final Store store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.hover : Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          showToast(context, '${store.name} dipilih');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.hairline))),
          child: Row(
            children: [
              Container(width: 4, height: 44, decoration: BoxDecoration(color: selected ? AppColors.brand : AppColors.inkAlpha(0.2), borderRadius: BorderRadius.circular(AppRadius.pill))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(store.address, style: TextStyle(fontSize: 12, color: AppColors.inkAlpha(0.6))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${store.distanceKm.toString().replaceAll('.', ',')} km', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(store.hoursNote, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: store.isOpen ? AppColors.brand : AppColors.inkAlpha(0.45))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
