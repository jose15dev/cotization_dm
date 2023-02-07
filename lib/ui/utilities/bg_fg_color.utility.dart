import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

abstract class BgFgColorUtility {
  static Color getFgForBg(int valueColor) {
    var index =
        Colors.primaries.indexWhere((element) => element.value == valueColor);
    var contract = (index + 1) / Colors.primaries.length;
    if (contract <= 0.5) {
      return ColorPalete.white;
    } else {
      return ColorPalete.black;
    }
  }

  static int getIndex(Color color) {
    return Colors.primaries
        .indexWhere((element) => element.value == color.value);
  }
}
