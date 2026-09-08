import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

enum _Step { phone, code }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.phone;
  final _phoneController = TextEditingController();
  String _code = '';
  bool _busy = false;

  String get _phoneE164 => '+62${_phoneController.text.trim()}';

  Future<void> _sendCode() async {
    if (_phoneController.text.trim().length < 6) {
      showToast(context, 'Masukkan nomor HP dulu');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).sendOtp(_phoneE164);
      if (mounted) setState(() => _step = _Step.code);
    } catch (e) {
      if (mounted) showToast(context, 'Gagal mengirim OTP: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.length != 4) {
      showToast(context, 'Isi 4 digit kode');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).verifyOtp(phoneE164: _phoneE164, code: _code);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) showToast(context, 'Kode salah atau kedaluwarsa');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guest() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).continueAsGuest();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) showToast(context, 'Gagal masuk sebagai guest: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _press(String key) {
    setState(() {
      if (key == '⌫') {
        if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
      } else if (_code.length < 4) {
        _code += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.panel,
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KOPI SPESIALTI · JAKARTA',
                        style: TextStyle(
                            fontSize: 10, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.55))),
                    const SizedBox(height: 16),
                    const Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: 'KOPI\n',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 46, height: 0.94, color: Colors.white)),
                        TextSpan(
                            text: 'RAKYAT',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 46, height: 0.94, color: AppColors.brand)),
                      ]),
                    ),
                    Container(margin: const EdgeInsets.symmetric(vertical: 17), height: 2, color: Colors.white24),
                    Text('Pesan sekarang, ambil tanpa antre. Kumpulkan cangkir tiap transaksi.',
                        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: _step == _Step.phone ? _phoneStep() : _codeStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nomor HP', style: _labelStyle),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.ink, width: 1.5), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppColors.border, width: 1.5))),
                child: const Text('+62', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '812 0000 0000',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BrandButton(label: 'Kirim kode OTP', trailing: const Icon(Icons.arrow_forward, color: Colors.white), onTap: _busy ? null : _sendCode),
        const SizedBox(height: 16),
        OutlineButton(label: 'Lanjut sebagai guest', onTap: _busy ? null : _guest),
        const SizedBox(height: 16),
        Text('Dengan lanjut, kamu setuju pada Syarat Layanan dan Kebijakan Privasi Kopi Rakyat.',
            style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.inkAlpha(0.5))),
      ],
    );
  }

  Widget _codeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.inkAlpha(0.7)), children: [
          const TextSpan(text: 'Kode 4 digit dikirim ke '),
          TextSpan(text: _phoneE164, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
          const TextSpan(text: '.'),
        ])),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: _code.length == i ? AppColors.brand : AppColors.inkAlpha(0.35), width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(i < _code.length ? _code[i] : '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 1.8,
            children: [
              for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'])
                Material(
                  color: AppColors.chrome,
                  child: InkWell(
                    onTap: key.isEmpty ? null : () => _press(key),
                    child: Center(child: Text(key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19))),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BrandButton(
          label: 'Verifikasi & masuk',
          trailing: const Icon(Icons.arrow_forward, color: Colors.white),
          enabled: _code.length == 4 && !_busy,
          onTap: _verify,
        ),
      ],
    );
  }
}

const _labelStyle = TextStyle(fontSize: 11, letterSpacing: 0.09, fontWeight: FontWeight.w600, color: AppColors.ink);
