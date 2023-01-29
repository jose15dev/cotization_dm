import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class DotIndicatorPainter extends BoxPainter {
  static double radius = 8.0;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final dx = configuration.size!.width / 2;
    final dy = configuration.size!.height + radius / 2;
    final c = offset + Offset(dx, dy);
    final paint = Paint()..color = ColorPalete.primary;
    canvas.drawCircle(c, radius, paint);
  }
}

class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return DotIndicatorPainter();
  }
}
