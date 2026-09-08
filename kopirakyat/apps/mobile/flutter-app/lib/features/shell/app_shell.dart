import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/cart_controller.dart';
import '../../theme/tokens.dart';

class _TabDef {
  const _TabDef(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

const _tabs = [
  _TabDef('/home', 'Beranda', Icons.home_rounded),
  _TabDef('/menu', 'Menu', Icons.local_cafe_outlined),
  _TabDef('/qr', 'Scan', Icons.qr_code_scanner_rounded),
  _TabDef('/merch', 'Merch', Icons.emoji_events_outlined),
  _TabDef('/profile', 'Saya', Icons.person_outline_rounded),
];

/// Persistent bottom tab bar for Beranda/Menu/Scan/Merch/Saya, shown on
/// home/menu/merch/locator/profile — matches `tabsDisplay` in the
/// prototype, which hides it on onboarding/product/cart/checkout/tracking/qr.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartControllerProvider.select((s) => s.cartCount));
    final activeIndex = _tabs.indexWhere((t) => t.path == location);

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.chrome,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      def: _tabs[i],
                      active: i == activeIndex,
                      badge: _tabs[i].path == '/menu' && cartCount > 0 ? cartCount : null,
                      onTap: () {
                        if (_tabs[i].path == '/qr') {
                          context.push('/qr');
                        } else {
                          context.go(_tabs[i].path);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.def, required this.active, required this.onTap, this.badge});

  final _TabDef def;
  final bool active;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brand : AppColors.inkAlpha(0.5);
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 26),
                color: active ? AppColors.brand : Colors.transparent,
              ),
              const SizedBox(height: 6),
              Icon(def.icon, size: 21, color: color),
              const SizedBox(height: 5),
              Text(
                def.label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.04, color: color),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 2,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '$badge',
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
