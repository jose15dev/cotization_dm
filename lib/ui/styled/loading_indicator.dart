import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  const LoadingIndicator({super.key, this.color, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            color: color ?? ColorPalete.primary,
          ),
        ),
      ),
    );
  }
}
