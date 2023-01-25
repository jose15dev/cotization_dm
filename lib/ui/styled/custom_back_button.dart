import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Function()? onTap;
  final Color? color;
  const CustomBackButton({Key? key, this.onTap, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var borderRadius2 = BorderRadius.circular(100);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius2,
        onTap: () => onTap != null ? onTap!() : Navigator.of(context).pop(),
        child: Ink(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: borderRadius2,
          ),
          child: Icon(
            size: 30,
            Icons.arrow_back_ios_new,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
