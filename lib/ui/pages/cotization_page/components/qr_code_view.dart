import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class QrCodeView extends StatelessWidget {
  final Cotization cotization;
  const QrCodeView({super.key, required this.cotization});

  Color get _foreground => BgFgColorUtility.getFgForBg(cotization.color);

  Color get _background => Color(cotization.color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: LayoutBuilder(builder: (context, constraints) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _background,
              iconTheme: IconThemeData(
                color: _foreground,
              ),
            ),
            SliverAppBar(
              toolbarHeight: constraints.maxHeight * 0.1,
              automaticallyImplyLeading: false,
              backgroundColor: _background,
              title: Column(
                children: [
                  Text(
                    cotization.name,
                    style: TextStyle(
                      color: _foreground,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    cotization.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: _foreground,
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * .05,
                vertical: constraints.maxHeight * 0.03,
              ),
              sliver: SliverToBoxAdapter(
                  child: SizedBox(
                height: constraints.maxHeight * 0.7,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: lerpDouble(0.5, 1, value),
                        child: child,
                      ),
                    );
                  },
                  child: AnimatedCardCotization(
                    cotization,
                    isQrCode: true,
                  ),
                ),
              )),
            ),
          ],
        );
      }),
    );
  }
}
