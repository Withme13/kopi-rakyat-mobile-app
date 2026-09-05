import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class SegmentedOption {
  const SegmentedOption({required this.label, this.sub = '', required this.selected, required this.onTap});

  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
}

/// A row of equal-width segments separated by 1px hairlines, active segment
/// filled dark — used for size/milk/ice/sugar in Product and "Waktu" in
/// Checkout (`this.seg(...)` / `whenOpts` in the prototype).
class SegmentedOptionRow extends StatelessWidget {
  const SegmentedOptionRow({super.key, required this.options});

  final List<SegmentedOption> options;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.divider),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 1),
              Expanded(child: _Segment(option: options[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.option});
  final SegmentedOption option;

  @override
  Widget build(BuildContext context) {
    final selected = option.selected;
    return Material(
      color: selected ? AppColors.panel : AppColors.muted,
      child: InkWell(
        onTap: option.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              if (option.sub.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    option.sub,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: (selected ? Colors.white : AppColors.ink).withValues(alpha: 0.65),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
