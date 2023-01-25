import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PropertieDialog extends StatefulWidget {
  final String label;
  final String? value;
  final List<TextInputFormatter> formatters;
  final TextInputType inputType;
  const PropertieDialog({
    super.key,
    required this.label,
    this.value,
    this.formatters = const [],
    this.inputType = TextInputType.text,
  });

  @override
  State<PropertieDialog> createState() => _PropertieDialogState();
}

class _PropertieDialogState extends State<PropertieDialog> {
  late TextEditingController controller;
  late String value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController(text: widget.value ?? "");
    value = widget.value ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var borderRadius = BorderRadius.circular(10.0);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          color: ColorPalete.white,
          width: 350,
          height: size.height * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: ColorPalete.primary,
                  child: Center(
                    child: CustomTextfield(
                      type: widget.inputType,
                      formatters: widget.formatters,
                      controller: controller,
                      foreground: ColorPalete.white,
                      label: widget.label,
                      fontSize: 30,
                      onChanged: (p0) => setState(() {
                        value = p0;
                      }),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Material(
                    child: InkWell(
                      borderRadius: borderRadius,
                      onTap: () => Navigator.of(context).pop(value),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: ColorPalete.primary.withOpacity(0.2),
                          borderRadius: borderRadius,
                        ),
                        child: Text("GUARDAR",
                            style: TextStyle(
                              fontSize: 30,
                              color: ColorPalete.primary,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
