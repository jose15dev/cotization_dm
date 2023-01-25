import 'package:flutter/material.dart';

const duration = Duration(milliseconds: 500);
PageRouteBuilder<T> fadeTransition<T>(Widget page) {
  return PageRouteBuilder<T>(
      pageBuilder: ((context, animation, secondaryAnimation) => page),
      transitionsBuilder: ((context, animation, secondaryAnimation, child) {
        return Align(
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      }),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: true);
}

PageRouteBuilder scaleTransition(Widget page) {
  return PageRouteBuilder(
      pageBuilder: ((context, animation, secondaryAnimation) => page),
      transitionsBuilder: ((context, animation, secondaryAnimation, child) {
        return Align(
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      }),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: true);
}
