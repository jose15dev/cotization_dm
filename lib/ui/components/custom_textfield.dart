import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextfield extends StatefulWidget {
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
  final bool enableError;
  final int maxLines;
  final Widget? suffixIcon;

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
    this.enableError = false,
    this.maxLines = 1,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  final FocusNode _focusNode = FocusNode();
  late bool _readOnly;
  late String _value;
  @override
  void initState() {
    super.initState();
    _readOnly = widget.readOnly;
    _value = widget.value;
    widget.stream?.listen((event) {
      if (widget.readOnly) {
        _value = event;
        setState(() {});
      }
    });
    _focusNode.addListener(() {
      if (widget.onChanged != null && widget.readOnly) {
        widget.onChanged!(_value);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_readOnly && mounted && widget.readOnly) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          _focusNode.unfocus();
          _readOnly = widget.readOnly;

          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var color = widget.foreground ?? ColorPalete.primary;

    return StreamBuilder<String>(
        stream: widget.stream,
        builder: (context, snapshot) {
          bool hasError = snapshot.error != null;
          Color currentColor = hasError ? ColorPalete.error : color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: TextField(
                focusNode: _focusNode,
                maxLines: widget.maxLines,
                onTap: () {
                  if (widget.readOnly) {
                    setState(() {
                      _readOnly = false;
                      _focusNode.requestFocus();
                    });
                  }
                },
                readOnly: _readOnly,
                cursorColor: currentColor,
                onChanged: (value) {
                  if (widget.onChanged is Function) widget.onChanged!(value);
                  _value = value;
                  setState(() {});
                },
                controller: _readOnly
                    ? TextEditingController(text: snapshot.data)
                    : widget.controller,
                textAlign: widget.align,
                style: TextStyle(
                  color: currentColor,
                  fontSize: widget.fontSize,
                ),
                keyboardType: widget.type,
                inputFormatters: widget.formatters,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: widget.label,
                  border: InputBorder.none,
                  errorText:
                      widget.enableError ? snapshot.error?.toString() : null,
                  errorStyle: TextStyle(
                    fontSize: widget.fontSize - 6,
                    color: ColorPalete.error,
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: TextStyle(
                    color: currentColor.withOpacity(0.8),
                  ),
                  filled: widget.filled,
                  suffixIcon: widget.suffixIcon,
                ),
              ),
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
