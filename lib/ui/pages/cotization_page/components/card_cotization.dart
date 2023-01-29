import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:math' as math;

class AnimatedCardCotization extends StatefulWidget {
  const AnimatedCardCotization(
    this.item, {
    Key? key,
    this.color,
    this.isDetail = false,
    this.isUpdated = false,
  }) : super(key: key);

  final Cotization item;
  final Color? color;
  final bool isDetail, isUpdated;

  @override
  State<AnimatedCardCotization> createState() => _AnimatedCardCotizationState();
}

class _AnimatedCardCotizationState extends State<AnimatedCardCotization>
    with TickerProviderStateMixin {
  Offset _currentDraggingOffset = Offset.zero;
  double _lastOffsetDy = 0.0;
  late AnimationController _animationController;

  void _onDragEnd(DragEndDetails details) {
    _lastOffsetDy = _currentDraggingOffset.dy;
    final animation = Tween<double>(begin: _lastOffsetDy, end: 0.0)
        .animate(_animationController);
    animation.addListener(() {
      if (mounted) {
        setState(() {
          _lastOffsetDy = animation.value;
          _currentDraggingOffset = Offset(0.0, _lastOffsetDy);
        });
      }
    });
    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0.0);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _lastOffsetDy += details.primaryDelta!;
    if (_lastOffsetDy < -180) {
      _lastOffsetDy = -180.0;
    }
    if (_lastOffsetDy > 180) {
      _lastOffsetDy = 180.0;
    }
    setState(() {
      _currentDraggingOffset = Offset(0.0, _lastOffsetDy);
    });
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get color => widget.color ?? Color(widget.item.color);
  final Color foreground = Colors.grey.shade900;
  final Color colorIcon = ColorPalete.white;
  double get currentAngle => (-math.pi / 180) * (_currentDraggingOffset.dy);
  bool get canAnimate =>
      widget.isDetail && (ModalRoute.of(context)?.animation?.value == 1.0);
  double get currentAngleBack =>
      (-math.pi / 180) * (_currentDraggingOffset.dy + 180);

  bool get displayBack => (currentAngle < -1.5 || currentAngle > 1.5);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return LayoutBuilder(builder: (context, constraints) {
            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onHorizontalDragUpdate: canAnimate ? _onDragUpdate : null,
                onHorizontalDragEnd: canAnimate ? _onDragEnd : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: _front(constraints)),
                    if (canAnimate && displayBack)
                      Positioned.fill(child: _back(constraints))
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _back(BoxConstraints constraints) {
    return Transform(
      alignment: Alignment.center,
      transform: canAnimate ? Matrix4.identity() : Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(currentAngleBack),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.item.isAccount
                        ? Text(
                            'CUENTA',
                            style: TextStyle(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            'COTIZACIÓN',
                            style: TextStyle(
                              color: color,
                              fontSize: 20,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight - 40,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                widget.item.isAccount ? 'CUENTA' : 'COTIZACIÓN',
                style: TextStyle(
                  color: ColorPalete.white,
                  fontFamily: fontFamily,
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _front(BoxConstraints constraints) {
    return Transform(
      alignment: Alignment.center,
      transform: canAnimate ? Matrix4.identity() : Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(currentAngle),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, 10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.item.isAccount
                            ? Text(
                                'CUENTA',
                                style: TextStyle(
                                  color: colorIcon,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                'COTIZACIÓN',
                                style: TextStyle(
                                  color: colorIcon,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight - 40,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorPalete.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.circleInfo,
                              size: 40, color: foreground),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name
                                  Row(
                                    children: [
                                      Text(
                                        widget.item.name,
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Description
                                  Text(
                                    widget.item.description,
                                    style: TextStyle(
                                      color: foreground,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                  ),
                                ]),
                          ),
                        ],
                      ),
                      // Total
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.commentDollar,
                              size: 40, color: foreground),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${CurrencyUtility.doubleToCurrency(widget.item.total)} COP",
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 25,
                                ),
                              ),
                              if (widget.item.tax is double)
                                Text(
                                  "IVA incluido",
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 18,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.item.finished) _brushstrokeTag(),
        ],
      ),
    );
  }

  Widget _brushstrokeTag() {
    return TweenAnimationBuilder(
        tween: widget.isUpdated
            ? Tween(begin: 0.0, end: 1.0)
            : Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        builder: (context, value, _) {
          return Opacity(
            opacity: value,
            child: Align(
              alignment: const FractionalOffset(1.25, .25),
              child: Transform.rotate(
                angle: lerpDouble(1, 0.5, value)!,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/brushstroke.png'),
                    ),
                  ),
                  width: 200,
                  height: 50,
                  child: Center(
                    child: Text(
                      "ENTREGADO",
                      style: TextStyle(
                        color: ColorPalete.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
