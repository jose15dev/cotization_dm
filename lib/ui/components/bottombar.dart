import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

class GradientBottomBar extends StatefulWidget {
  final List<Widget> actions;
  final List<Color> colors;
  const GradientBottomBar({
    Key? key,
    required this.actions,
    required this.colors,
  }) : super(key: key);

  @override
  State<GradientBottomBar> createState() => _GradientBottomBarState();
}

class _GradientBottomBarState extends State<GradientBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..forward()
      ..addListener(() {
        if (_backgroundController.isCompleted) {
          _backgroundController.repeat();
        }
      });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, _) {
          return Container(
            height: kBottomNavigationBarHeight * 1.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                transform:
                    GradientRotation(2 * math.pi * _backgroundController.value),
                colors: widget.colors,
              ),
            ),
            child: Row(children: widget.actions),
          );
        });
  }
}

class GradientAction extends StatelessWidget {
  const GradientAction({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final GestureTapDownCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: ColorPalete.white,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: ColorPalete.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
