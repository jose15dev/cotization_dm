import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function()? onTap;
  const OptionPage(
      {super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    var fontSize = 15.0;
    var borderRadius = BorderRadius.circular(20.0);
    var width = 70.0;
    var height = 70.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Ink(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: ColorPalete.secondary,
              ),
              child: Icon(
                icon,
                size: fontSize + 15,
                color: ColorPalete.primary,
              ),
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
