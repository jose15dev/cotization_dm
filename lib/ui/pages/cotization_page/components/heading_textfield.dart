import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeadingTextField extends StatelessWidget {
  final String title;
  final double fontSize;
  final int maxLines;
  final Color? color;
  final void Function(String)? onChange;
  final List<TextInputFormatter> formatters;
  final TextInputType type;
  final Stream<String>? stream;
  final TextEditingController? controller;
  const HeadingTextField({
    Key? key,
    required this.title,
    required this.fontSize,
    this.maxLines = 1,
    this.color,
    this.controller,
    this.onChange,
    this.formatters = const [],
    this.stream,
    this.type = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: onChange,
            controller: controller,
            cursorColor: color,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
            ),
            inputFormatters: formatters,
            keyboardType: type,
            maxLines: maxLines,
            minLines: 1,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorText: snapshot.error?.toString(),
              hintText: title,
              hintStyle: TextStyle(
                color: color?.withOpacity(0.6),
              ),
              border: InputBorder.none,
            ),
          );
        });
  }
}
