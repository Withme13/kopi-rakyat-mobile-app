import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/fulfilment_mode.dart';
import '../../state/cart_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

const _tableNumbers = ['01', '02', '03', '05', '06', '07', '08', '09'];

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  String? _pick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.panel,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(children: [
                CircleIconButton(icon: Icons.arrow_back, dark: true, onTap: () => context.pop()),
                const SizedBox(width: 12),
                const Text('Scan meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.18)))),
                          for (final corner in _Corner.values) _ScanCorner(corner: corner),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text('Arahkan kamera ke QR di meja',
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Colors.white54, height: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('ATAU PILIH MEJA MANUAL', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white54)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.6,
                      children: [
                        for (final t in _tableNumbers)
                          GestureDetector(
                            onTap: () => setState(() => _pick = t),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _pick == t ? AppColors.brand : Colors.transparent,
                                border: Border.all(color: _pick == t ? AppColors.brand : Colors.white38, width: 1.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: BrandButton(
                label: _pick != null ? 'Pesan untuk meja $_pick' : 'Pilih meja untuk lanjut',
                enabled: _pick != null,
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                onTap: () {
                  if (_pick == null) {
                    showToast(context, 'Pilih nomor meja dulu');
                    return;
                  }
                  ref.read(cartControllerProvider.notifier)
                    ..setTable(_pick)
                    ..setFulfilmentMode(FulfilmentMode.dineIn);
                  showToast(context, 'Meja $_pick · pesanan diantar ke meja');
                  context.go('/menu');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.corner});
  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.brand, width: 4);
    final isTop = corner == _Corner.topLeft || corner == _Corner.topRight;
    final isLeft = corner == _Corner.topLeft || corner == _Corner.bottomLeft;
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? side : BorderSide.none,
            bottom: isTop ? BorderSide.none : side,
            left: isLeft ? side : BorderSide.none,
            right: isLeft ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}
