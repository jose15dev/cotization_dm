import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class FinishDialog extends StatelessWidget {
  final String title;
  const FinishDialog({
    Key? key,
    required this.selectedColor,
    required this.title,
  }) : super(key: key);

  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        title,
        style: TextStyle(
          color: ColorPalete.black,
          fontSize: 18,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            "Si",
            style: TextStyle(
              color: selectedColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "No",
            style: TextStyle(
              color: selectedColor,
            ),
          ),
        ),
      ],
    );
  }
}
