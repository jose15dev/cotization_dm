import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotateBackground extends StatefulWidget {
  final Widget? child;
  final double padding, radius;
  final List<Color> colors;
  const RotateBackground(
      {this.child,
      super.key,
      required this.padding,
      required this.radius,
      this.colors = const []});

  @override
  State<RotateBackground> createState() => _RotateBackgroundState();
}

class _RotateBackgroundState extends State<RotateBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            padding: EdgeInsets.all(widget.padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                transform: GradientRotation(_controller.value * 2 * math.pi),
                colors: widget.colors.isEmpty
                    ? [
                        ColorPalete.primary,
                        ColorPalete.secondary,
                      ]
                    : widget.colors,
              ),
            ),
            child: widget.child,
          );
        });
  }
}
