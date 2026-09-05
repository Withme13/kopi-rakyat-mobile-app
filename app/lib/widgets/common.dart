import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/tokens.dart';

String formatRupiah(num amount) => 'Rp ${NumberFormat('#,##0', 'id_ID').format(amount).replaceAll(',', '.')}';

void showToast(BuildContext context, String message, {VoidCallback? onViewCart}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.panel,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Container(width: 8, height: 8, color: AppColors.brand),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          if (onViewCart != null)
            TextButton(
              onPressed: onViewCart,
              child: const Text('Lihat keranjang', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    ),
  );
}

/// A photo "drop slot" placeholder — the prototype ships with empty
/// grayscale image slots for real product photography to be dropped in
/// later; this renders the same neutral placeholder state.
class PhotoSlot extends StatelessWidget {
  const PhotoSlot({super.key, this.icon = Icons.image_outlined, this.radius = AppRadius.card});

  final IconData icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.placeholder, borderRadius: BorderRadius.circular(radius)),
      child: Center(child: Icon(icon, color: AppColors.inkAlpha(0.28), size: 28)),
    );
  }
}

class RemotePhoto extends StatelessWidget {
  const RemotePhoto({
    super.key,
    required this.imageUrl,
    this.icon = Icons.image_outlined,
    this.radius = AppRadius.card,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final IconData icon;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return PhotoSlot(icon: icon, radius: radius);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => PhotoSlot(icon: icon, radius: radius),
      ),
    );
  }
}

class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_outlined, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.015)),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('Lihat Semua',
                style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ),
      ],
    );
  }
}

class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.label,
    this.trailing,
    this.leading,
    this.onTap,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.brand : AppColors.inkAlpha(0.3),
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: enabled ? onTap : null,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, this.onTap, this.height = 52});

  final String label;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, this.onTap, this.outlined = true, this.dark = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool outlined;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: outlined
                ? Border.all(color: dark ? Colors.white.withValues(alpha: 0.45) : AppColors.ink, width: 1.5)
                : null,
          ),
          child: Icon(icon, size: 19, color: dark ? Colors.white : AppColors.ink),
        ),
      ),
    );
  }
}

class CardSurface extends StatelessWidget {
  const CardSurface({super.key, required this.child, this.padding, this.onTap, this.radius = AppRadius.card});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
