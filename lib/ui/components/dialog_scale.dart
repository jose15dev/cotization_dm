import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

Future<T?> dialogScale<T>(
    BuildContext context, Offset currentPosition, Widget content) {
  final dx = currentPosition.dx / MediaQuery.of(context).size.width;
  final dy = currentPosition.dy / MediaQuery.of(context).size.height;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Label",
    barrierColor: ColorPalete.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var tween = CurveTween(curve: Curves.easeOutCirc).animate(animation);
      return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Transform(
              alignment: FractionalOffset(dx, dy),
              transform: Matrix4.identity()..scale(tween.value),
              child: child,
            );
          });
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: FractionalOffset.center,
        child: content,
      );
    },
  );
}
