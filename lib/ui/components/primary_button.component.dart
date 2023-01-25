import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final IconData? icon;
  final bool bordered;
  final bool textOnly;
  final double fontSize;
  const PrimaryButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.textOnly = false,
    this.bordered = false,
    this.fontSize = 22,
  });
  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(15.0);
    var foreground = bordered ? ColorPalete.primary : ColorPalete.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: bordered ? ColorPalete.white : ColorPalete.primary,
            border: _border(),
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize, color: foreground),
                  const SizedBox(width: 10)
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
