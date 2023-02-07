import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class _DotIndicatorPainter extends BoxPainter {
  double radius = 8.0;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final dx = configuration.size!.width / 2;
    final dy = configuration.size!.height + radius / 2;
    final c = offset + Offset(dx, dy);
    final paint = Paint()..color = ColorPalete.primary;
    canvas.drawCircle(c, radius, paint);
  }
}

class DotCircleIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotIndicatorPainter();
  }
}

class DotPlaneIndicatorPainter extends BoxPainter {
  final Color color;
  double size = 30.0;

  DotPlaneIndicatorPainter(this.color);
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final begin =
        offset + Offset(_getCentry(configuration), configuration.size!.height);
    final end = offset +
        Offset(_getCentry(configuration) + size, configuration.size!.height);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(begin, end, paint);
  }

  double _getCentry(ImageConfiguration configuration) =>
      (configuration.size!.width / 2) - (size / 2);
}

class DotPlaneIndicator extends Decoration {
  final Color? color;

  const DotPlaneIndicator([this.color]);
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return DotPlaneIndicatorPainter(color ?? ColorPalete.primary);
  }
}
