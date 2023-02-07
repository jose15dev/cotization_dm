import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:math' as math;

import 'package:qr_flutter/qr_flutter.dart';

class AnimatedCardCotization extends StatefulWidget {
  const AnimatedCardCotization(
    this.item, {
    Key? key,
    this.isDetail = false,
    this.color,
  }) : super(key: key);

  final Cotization item;
  final Color? color;
  final bool isDetail;

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

  Color get _coverBackground => widget.color ?? Color(widget.item.color);
  Color get _coverForeground =>
      BgFgColorUtility.getFgForBg(_coverBackground.value);
  double get currentAngle => (-math.pi / 180) * (_currentDraggingOffset.dy);
  bool get canAnimate =>
      widget.isDetail && (ModalRoute.of(context)?.animation?.value == 1.0);
  double get currentAngleBack =>
      (-math.pi / 180) * (_currentDraggingOffset.dy + 180);

  bool get displayBack => (currentAngle < -1.5 || currentAngle > 1.5);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            return LayoutBuilder(builder: (context, constraints) {
              return GestureDetector(
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
              );
            });
          }),
    );
  }

  Widget _back(BoxConstraints constraints) {
    return Transform(
      alignment: Alignment.center,
      transform: canAnimate ? Matrix4.identity() : Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(currentAngleBack),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: _FolderClipper(inverted: true),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: _coverBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImage(
                    data: widget.item.id.toString(),
                    size: constraints.maxHeight * .4,
                    foregroundColor: _coverForeground,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.item.isAccount ? 'CUENTA' : 'COTIZACIÓN',
                    style: TextStyle(
                      color: _coverForeground,
                      fontFamily: fontFamily,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: CustomPaint(
              painter: _FolderBorderPainter(
                color: _coverForeground,
                inverted: true,
              ),
            ),
          )
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
          Positioned.fill(
            child: ClipPath(
              clipper: _FolderClipper(
                radius: 20.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _coverBackground,
                ),
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 20.0,
                  bottom: 15.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.circleInfo,
                            size: 40, color: _coverForeground),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Name
                                Row(
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth * .7,
                                      child: AutoSizeText(
                                        widget.item.name,
                                        presetFontSizes: const [30, 25, 20],
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _coverForeground,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Description
                                Text(
                                  widget.item.description,
                                  style: TextStyle(
                                    color: _coverForeground,
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
                            size: 40, color: _coverForeground),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${CurrencyUtility.doubleToCurrency(widget.item.total)} COP",
                              style: TextStyle(
                                color: _coverForeground,
                                fontSize: 25,
                              ),
                            ),
                            if (widget.item.tax is double)
                              Text(
                                "IVA incluido",
                                style: TextStyle(
                                  color: _coverForeground,
                                  fontSize: 18,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Last update and Finish
                    if (widget.item.finished == null &&
                        widget.item.deletedAt == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Actualizado ${TimeAgoUtility.toTimeAgo(widget.item.updatedAt)}",
                            style: TextStyle(
                              color: _coverForeground,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    if (widget.item.finished != null &&
                        widget.item.deletedAt == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Entregado ${TimeAgoUtility.toTimeAgo(widget.item.finished!)}",
                            style: TextStyle(
                              color: _coverForeground,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    if (widget.item.deletedAt != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Eliminado ${TimeAgoUtility.toTimeAgo(widget.item.deletedAt!)}",
                            style: TextStyle(
                              color: _coverForeground,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight - 40,
            child: CustomPaint(
              painter: _FolderBorderPainter(
                color: _coverForeground,
              ),
            ),
          ),
          // if (widget.item.finished is DateTime) _brushstrokeTag(),
        ],
      ),
    );
  }
}

Path getPath(Size size, double topPadding, double radius, bool inverted) {
  double clipWidth = size.width / 3;
  late Path path;
  if (inverted) {
    path = Path()
      ..moveTo(0.0, topPadding + radius)
      ..lineTo(radius, topPadding)
      ..lineTo(size.width - clipWidth, topPadding)
      ..lineTo(size.width - clipWidth + radius, 0.0)
      ..lineTo(size.width - radius, 0.0)
      ..lineTo(size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..lineTo(size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..lineTo(0.0, size.height - topPadding)
      ..lineTo(0.0, size.height - topPadding)
      ..close();
  } else {
    path = Path()
      ..moveTo(0.0, radius)
      ..lineTo(radius, 0.0)
      ..lineTo(clipWidth - radius, 0.0)
      ..lineTo(clipWidth, topPadding)
      ..lineTo(size.width - radius, topPadding)
      ..lineTo(size.width, topPadding + radius)
      ..lineTo(size.width, size.height - radius)
      ..lineTo(size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..lineTo(0.0, size.height - radius)
      ..close();
  }

  return path;
}

class _FolderClipper extends CustomClipper<Path> {
  final double topPadding;
  final double radius;
  final bool inverted;

  _FolderClipper(
      {this.inverted = false, this.topPadding = 20.0, this.radius = 20.0});
  @override
  Path getClip(Size size) {
    return getPath(size, topPadding, radius, inverted);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _FolderBorderPainter extends CustomPainter {
  final double topPadding;
  final double radius;
  final bool inverted;
  final Color color;

  _FolderBorderPainter({
    this.inverted = false,
    this.topPadding = 20.0,
    this.radius = 20.0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = color;

    final path = getPath(size, topPadding, radius, inverted);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
