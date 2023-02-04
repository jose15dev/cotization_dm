import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SineCurve extends Curve {
  const SineCurve({this.count = 3});
  final double count;

  @override
  double transformInternal(double t) {
    return math.sin(count * 2 * math.pi * t);
  }
}
