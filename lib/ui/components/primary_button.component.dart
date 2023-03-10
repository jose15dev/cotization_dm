import 'package:auto_size_text/auto_size_text.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final GestureTapDownCallback? onTapDown;
  final IconData? icon;
  final bool bordered;
  final bool textOnly;
  final double fontSize;
  final List<Color> gradientColors;
  final Color? foreground;
  const CustomButton(
    this.label, {
    super.key,
    this.onTap,
    this.onTapDown,
    this.icon,
    this.textOnly = false,
    this.bordered = false,
    this.foreground,
    this.gradientColors = const [],
    this.fontSize = 22,
  });
  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(15.0);
    var currentForeground =
        bordered ? foreground ?? ColorPalete.primary : ColorPalete.white;
    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onTapDown: onTapDown,
          borderRadius: borderRadius,
          child: Ink(
            width: constraints.maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: gradientColors.isNotEmpty
                  ? null
                  : bordered
                      ? ColorPalete.white
                      : ColorPalete.primary,
              gradient: gradientColors.isNotEmpty
                  ? LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: _border(),
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize, color: currentForeground),
                    const SizedBox(width: 10)
                  ],
                  Expanded(
                    child: AutoSizeText(
                      label,
                      presetFontSizes: [fontSize, fontSize - 2, fontSize - 4],
                      style: TextStyle(
                        color: currentForeground,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Border? _border() {
    if (textOnly) {
      return null;
    }
    return bordered
        ? Border.all(
            width: 2,
            color: ColorPalete.primary,
          )
        : null;
  }
}
