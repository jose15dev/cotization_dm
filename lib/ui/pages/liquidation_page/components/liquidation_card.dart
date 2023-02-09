import 'package:auto_size_text/auto_size_text.dart';
import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AnimatedLiquidationCard extends StatelessWidget {
  const AnimatedLiquidationCard({
    Key? key,
    required this.liquidation,
    required this.colors,
  }) : super(key: key);

  final Liquidation liquidation;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    var employee = liquidation.employee;
    var backgroundColor = ColorPalete.secondary;
    var borderColor = ColorPalete.white;
    var textColor = ColorPalete.white;
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: _CustomClipper(),
            child: RotateBackground(
              colors: colors,
              radius: 0,
              padding: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.dollarSign,
                        size: constraints.maxHeight * .25,
                        color: textColor,
                      ),
                      Expanded(
                          child: AutoSizeText(
                        "${CurrencyUtility.doubleToCurrencyWithOutDollarSign(liquidation.realPrice)} COP",
                        presetFontSizes: [
                          constraints.maxHeight * .2,
                          constraints.maxHeight * .16,
                          constraints.maxHeight * .1,
                        ],
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: textColor,
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: constraints.maxHeight * .07,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      // Employee names
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.firstname,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: constraints.maxHeight * .08,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                employee.lastname,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: constraints.maxHeight * .08,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Por concepto de:",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: constraints.maxHeight * .06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    liquidation.days.toString(),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: constraints.maxHeight * .12,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Días de trabajo",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: constraints.maxHeight * .06,
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      // Created at
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            QrImage(
                              data: liquidation.id.toString(),
                              foregroundColor: textColor,
                              size: constraints.maxHeight * .4,
                            ),
                            Text(
                              TimeAgoUtility.toTimeAgo(liquidation.createdAt),
                              style: TextStyle(
                                color: textColor,
                                fontSize: constraints.maxHeight * .06,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              ),
            ),
          ),
          SizedBox(
            child: CustomPaint(
              painter: _CustomBorderPainter(color: borderColor),
            ),
          )
        ],
      );
    });
  }
}

class _CustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _CustomBorderPainter extends CustomPainter {
  final Color color;

  _CustomBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    var path = _getPath(size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _getPath(Size size) {
  double corner = 20.0;
  return Path()
    ..moveTo(0, corner)
    ..lineTo(corner, 0)
    ..lineTo(size.width - corner, 0)
    ..lineTo(size.width, corner)
    ..lineTo(size.width, size.height - corner)
    ..lineTo(size.width - corner, size.height)
    ..lineTo(corner, size.height)
    ..lineTo(0, size.height - corner)
    ..lineTo(0, corner);
}
