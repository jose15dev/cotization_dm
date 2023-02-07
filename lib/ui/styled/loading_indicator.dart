import 'dart:ui';

import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final int count;
  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 80,
    this.count = 3,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<List<Animation<double>>> _animations;

  final _duration = 300.0;
  late int _count;
  @override
  void initState() {
    super.initState();
    _count = widget.count + 1;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_duration * _count).toInt()),
    )..repeat();

    _animations = List.generate(
      widget.count,
      (index) {
        return [
          CurveTween(
              curve: Interval(
            index / _count,
            (index + 1) / _count,
            curve: Curves.easeInOut,
          )).animate(_controller),
          CurveTween(
              curve: Interval(
            (index + 1) / _count,
            (index + 2) / _count,
            curve: Curves.easeInOut,
          )).animate(_controller),
        ];
      },
    );
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
          return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Row(
                children: List.generate(widget.count, (index) {
                  return Expanded(
                    child: CustomPaint(
                      painter: _CirclePainter(
                        progress: _animations[index][0].value -
                            _animations[index][1].value,
                        color: widget.color,
                      ),
                    ),
                  );
                }),
              ));
        });
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color? color;
  final minRadius = 5.0;
  final maxRadius = 12.0;

  _CirclePainter({
    this.color,
    required this.progress,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color ?? ColorPalete.primary;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        lerpDouble(minRadius, maxRadius, progress)!, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
