import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../state/profile_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

class _Row {
  const _Row(this.icon, this.label, {this.count, this.tag, this.isToggle = false, this.onTap});
  final IconData icon;
  final String label;
  final String? count;
  final String? tag;
  final bool isToggle;
  final void Function(BuildContext context, WidgetRef ref)? onTap;
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final isSignedIn = ref.watch(isSignedInProvider);
    final profile = profileAsync.value;
    final userName = profile?.fullName ?? (isSignedIn ? 'Rangga' : 'Fais');

    final groups = <String, List<_Row>>{
      'Akun': [
        _Row(Icons.inbox_outlined, 'Kotak Masuk', count: '2', onTap: (c, r) => showToast(c, '2 pesan belum dibaca')),
        _Row(Icons.location_on_outlined, 'Alamat Pengiriman', onTap: (c, r) => showToast(c, 'Daftar alamat menyusul')),
        _Row(Icons.qr_code_scanner_outlined, 'Scan Merchandise', onTap: (c, r) => c.push('/qr')),
        _Row(Icons.fingerprint, 'Aktifkan Biometric ID', isToggle: true,
            onTap: (c, r) => r.read(profileControllerProvider.notifier).setBiometricEnabled(!(profile?.biometricEnabled ?? false))),
        _Row(Icons.language, 'Ubah Bahasa Aplikasi', onTap: (c, r) => showToast(c, 'Bahasa: Indonesia · English')),
      ],
      'Pesan': [
        _Row(Icons.receipt_long_outlined, 'Riwayat Pesanan', onTap: (c, r) {
          final last = r.read(orderRepositoryProvider).lastOrder;
          if (last != null) {
            c.push('/tracking/${last.id}');
          } else {
            showToast(c, 'Belum ada pesanan aktif');
          }
        }),
        _Row(Icons.credit_card, 'Metode Pembayaran', onTap: (c, r) => c.push('/checkout')),
        _Row(Icons.local_shipping_outlined, 'Pesanan Jumlah Besar', tag: 'Baru', onTap: (c, r) => showToast(c, 'Form pesanan grosir menyusul')),
      ],
      'Kopi Rakyat': [
        _Row(Icons.help_outline, 'Bantuan', onTap: (c, r) => showToast(c, 'Pusat bantuan menyusul')),
        _Row(Icons.privacy_tip_outlined, 'Kebijakan Privasi', onTap: (c, r) => showToast(c, 'Membuka kebijakan privasi')),
        _Row(Icons.description_outlined, 'Ketentuan Layanan', onTap: (c, r) => showToast(c, 'Membuka ketentuan layanan')),
        _Row(Icons.flag_outlined, 'Lapor Masalah', onTap: (c, r) => showToast(c, 'Form laporan masalah menyusul')),
        _Row(Icons.chat_outlined, 'Layanan WhatsApp', onTap: (c, r) => showToast(c, 'Menghubungkan ke CS WhatsApp')),
        _Row(Icons.favorite_border, 'Tentang Kopi Rakyat', onTap: (c, r) => showToast(c, 'Kopi Rakyat · kopi spesialti Jakarta sejak 2024')),
      ],
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 106,
                  color: AppColors.panel,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 18, 0),
                      child: GestureDetector(
                        onTap: () => showToast(context, 'Form edit profil menyusul'),
                        child: const Row(
                          children: [
                            Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            SizedBox(width: 7),
                            Icon(Icons.edit_outlined, color: Colors.white, size: 17),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 64,
                  child: CardSurface(
                    radius: 20,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 37,
                          backgroundColor: AppColors.card,
                          child: CircleAvatar(radius: 33, backgroundColor: AppColors.hover, child: Icon(Icons.person, color: AppColors.inkAlpha(0.4), size: 30)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hai,', style: TextStyle(fontSize: 14, color: AppColors.inkAlpha(0.55))),
                                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.02)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 14),
                              decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.hairline))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Level', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                                  Text(profile?.tier ?? 'Silver', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 12),
                              margin: const EdgeInsets.only(left: 12),
                              decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.hairline))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Poin Rakyat', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                                  Text('${profile?.points ?? 1200}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 74),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CardSurface(
                radius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Promo Spesial Buat Kamu!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.brand, height: 1.25)),
                              SizedBox(height: 10),
                              Text('Ikuti channel kami dan jangan lewatkan penawaran menarik setiap saat.',
                                  style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.ink)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(width: 120, height: 104, child: PhotoSlot(radius: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BrandButton(
                      label: 'Ikuti Sekarang',
                      leading: const Icon(Icons.campaign_outlined, color: Colors.white),
                      onTap: () => showToast(context, 'Membuka channel Kopi Rakyat'),
                    ),
                  ],
                ),
              ),
            ),
            for (final entry in groups.entries)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.02)),
                    ),
                    CardSurface(
                      radius: 20,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < entry.value.length; i++)
                            _SettingsRow(row: entry.value[i], showDivider: i != entry.value.length - 1, biometricOn: profile?.biometricEnabled ?? false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 4),
              child: Text('Versi Aplikasi 1.0.26', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.inkAlpha(0.42))),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, color: AppColors.goldText),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Order menggunakan apps', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
                    GestureDetector(
                      onTap: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/onboarding');
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(color: AppColors.brandAlt, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: const Text('Ulangi Tutorial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.row, required this.showDivider, required this.biometricOn});
  final _Row row;
  final bool showDivider;
  final bool biometricOn;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: row.onTap == null ? null : () => row.onTap!(context, ref),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: showDivider ? AppColors.hairline : Colors.transparent))),
            child: Row(
              children: [
                Icon(row.icon, size: 22, color: AppColors.inkAlpha(0.72)),
                const SizedBox(width: 14),
                Expanded(child: Text(row.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
                if (row.count != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(row.count!, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                if (row.tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(10)),
                    child: Text(row.tag!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                if (row.isToggle)
                  Container(
                    width: 52,
                    height: 30,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: biometricOn ? AppColors.brand : const Color(0xFFD3D2CF), borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 150),
                      alignment: biometricOn ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ),
                  ),
                if (!row.isToggle && row.count == null && row.tag == null) Icon(Icons.chevron_right, color: const Color(0xFFA98A4B)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
