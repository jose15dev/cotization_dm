import 'package:flutter/material.dart';

class OrderTag extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final IconData icon;
  const OrderTag({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(10.0);
    var foreground = Colors.grey.shade600;
    var background = Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: foreground,
              ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
