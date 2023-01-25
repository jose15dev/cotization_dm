import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield extends StatelessWidget {
  final String label;
  final List<TextInputFormatter> formatters;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType type;
  final Stream<String>? stream;
  final double fontSize;
  final Color? foreground;
  final TextAlign align;
  final bool filled;
  final bool readOnly;
  final String value;

  const CustomTextfield({
    Key? key,
    required this.label,
    this.onChanged,
    this.controller,
    this.foreground,
    this.type = TextInputType.text,
    this.formatters = const [],
    this.stream,
    this.fontSize = 18,
    this.align = TextAlign.center,
    this.filled = false,
    this.readOnly = false,
    this.value = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = foreground ?? ColorPalete.primary;
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          bool isError = snapshot.error != null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              readOnly: readOnly,
              cursorColor: color,
              onChanged: onChanged,
              controller:
                  readOnly ? TextEditingController(text: value) : controller,
              textAlign: align,
              style: TextStyle(
                color: isError ? ColorPalete.error : color,
                fontSize: fontSize,
              ),
              keyboardType: type,
              inputFormatters: formatters,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: label,
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: fontSize,
                    color: ColorPalete.error,
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: TextStyle(
                    color: foreground?.withOpacity(0.8) ?? Colors.grey.shade600,
                  ),
                  filled: filled),
            ),
          );
        });
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  PhoneInputFormatter();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    const mask = "xxx-xxx-xxxx";
    const separator = "-";
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}
