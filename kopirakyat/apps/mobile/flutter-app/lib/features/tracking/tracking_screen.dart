import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/fulfilment_mode.dart';
import '../../models/order.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

const _times = ['09.41', '09.43', '09.47', '09.52'];
const _etaByStage = [
  'Estimasi siap 09.47',
  'Barista sedang membuat pesananmu',
  'Pesanan siap — tunjukkan kode',
  'Pesanan selesai',
];

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  AppOrder? _order;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await ref.read(orderRepositoryProvider).fetchOrder(widget.orderId);
    if (!mounted) return;
    setState(() => _order = order);
    _scheduleAdvance();
  }

  void _scheduleAdvance() {
    _timer?.cancel();
    if ((_order?.stage ?? 3) >= 3) return;
    _timer = Timer(const Duration(milliseconds: 3600), () async {
      final updated = await ref.read(orderRepositoryProvider).advanceStage(widget.orderId);
      if (!mounted) return;
      setState(() => _order = updated);
      _scheduleAdvance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<(String, String)> _stageTitles(AppOrder order) {
    if (order.fulfilmentMode == FulfilmentMode.delivery) {
      return const [
        ('Pesanan diterima', 'Barista mulai menyiapkan'),
        ('Sedang dibuat', 'Espresso ditarik, susu di-steam'),
        ('Kurir menuju kamu', 'Rizky · B 3421 TXG'),
        ('Selesai', 'Terima kasih, sampai besok'),
      ];
    }
    final thirdTitle = order.fulfilmentMode == FulfilmentMode.dineIn ? 'Diantar ke meja' : 'Siap diambil';
    final thirdSub = order.fulfilmentMode == FulfilmentMode.dineIn
        ? 'Meja ${order.tableNumber ?? '07'}'
        : 'Konter ${order.storeName}';
    return [
      ('Pesanan diterima', 'Pembayaran ${order.paymentMethod} berhasil'),
      ('Sedang dibuat', 'Espresso ditarik, susu di-steam'),
      (thirdTitle, thirdSub),
      ('Selesai', 'Terima kasih, sampai besok'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final stageTitles = _stageTitles(order);
    final stage = order.stage;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Container(
              color: AppColors.panel,
              padding: const EdgeInsets.all(22),
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
                            Text('PESANAN ${order.orderNo}',
                                style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.55))),
                            const SizedBox(height: 8),
                            Text(stageTitles[stage].$1,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.025, height: 1.1)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.close, color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: i <= stage ? AppColors.brand : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_etaByStage[stage], style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < stageTitles.length; i++) _StageRow(index: i, stage: stage, title: stageTitles[i].$1, sub: stageTitles[i].$2, time: _times[i], isLast: i == stageTitles.length - 1),
                  CardSurface(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KODE PENGAMBILAN', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(order.pickupCode ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 38, letterSpacing: 1.5)),
                            const Spacer(),
                            Text('Tunjukkan kode\ndi konter ${order.storeName}',
                                textAlign: TextAlign.right, style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.inkAlpha(0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: OutlineButton(label: 'Tambah pesanan', height: 48, onTap: () => context.go('/menu'))),
                      const SizedBox(width: 10),
                      Expanded(child: BrandButton(label: 'Sudah diambil', height: 48, onTap: () => context.go('/merch'))),
                    ],
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

class _StageRow extends StatelessWidget {
  const _StageRow({required this.index, required this.stage, required this.title, required this.sub, required this.time, required this.isLast});
  final int index;
  final int stage;
  final String title;
  final String sub;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = index <= stage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.brand : AppColors.muted,
                  border: Border.all(color: done ? AppColors.brand : AppColors.inkAlpha(0.35), width: 2),
                ),
              ),
              if (!isLast) Container(width: 2, height: 30, color: index < stage ? AppColors.brand : AppColors.divider),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: done ? AppColors.ink : AppColors.inkAlpha(0.45))),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.inkAlpha(0.6))),
              ],
            ),
          ),
          Text(done ? time : '—', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkAlpha(0.5))),
        ],
      ),
    );
  }
}
