import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import 'tokens.dart';

/// The "mega mendung" cloud motif from the prototype's `.batik` background:
/// layered cloud arches, 2.2px stroke at 7.5% opacity, tiled 240×150 —
/// see `Kopi Rakyat App.dc.html` (search `.batik`).
class BatikBackground extends StatelessWidget {
  const BatikBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: CustomPaint(
        painter: _MegaMendungPainter(),
        child: child,
      ),
    );
  }
}

const _tileWidth = 240.0;
const _tileHeight = 150.0;

const _cloudArch =
    'M-20 118c0-26 20-46 46-46s40 18 40 34c0-13 10-24 25-24s26 11 26 25'
    'c0-11 8-20 20-20s21 9 21 21c0-9 7-16 17-16s18 8 18 18';

List<String> get _tilePaths => [
      _cloudArch,
      _cloudArch.replaceFirst('118', '100'),
      _cloudArch.replaceFirst('118', '82'),
    ];

const _smallArch =
    'M100 43c0-26 20-46 46-46s40 18 40 34c0-13 10-24 25-24s26 11 26 25'
    'c0-11 8-20 20-20';

class _MegaMendungPainter extends CustomPainter {
  static final List<Path> _tile = [
    for (final d in _tilePaths) parseSvgPathData(d),
    _translated(parseSvgPathData(_smallArch), -140, -8),
    _translated(parseSvgPathData(_smallArch), -140, -26),
  ];

  static Path _translated(Path path, double dx, double dy) =>
      path.shift(Offset(dx, dy));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final cols = (size.width / _tileWidth).ceil() + 1;
    final rows = (size.height / _tileHeight).ceil() + 1;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final offset = Offset(col * _tileWidth, row * _tileHeight);
        for (final path in _tile) {
          canvas.drawPath(path.shift(offset), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
