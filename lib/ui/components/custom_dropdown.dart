import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

abstract class DropdownData<T> {
  T value();
}

class CustomDrowpdown<T> extends StatelessWidget {
  final List<DropdownData<T>> items;
  final Function(T value)? onChange;
  final T? value;
  final double width;
  final bool enabled;
  const CustomDrowpdown({
    super.key,
    required this.items,
    this.onChange,
    this.value,
    this.width = 120,
    this.enabled = true,
  }) : assert(items.length > 0);

  @override
  Widget build(BuildContext context) {
    var color = enabled ? ColorPalete.secondary : Colors.grey.shade300;
    var foreground = enabled ? ColorPalete.primary : Colors.grey.shade600;
    var borderRadius = BorderRadius.circular(20);
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DropdownButtonFormField<T>(
          borderRadius: borderRadius,
          alignment: FractionalOffset.center,
          elevation: 0,
          decoration: InputDecoration(
              border: InputBorder.none, fillColor: color, filled: true),
          value: value,
          menuMaxHeight: 250,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e.value(),
                    child: Text(e.toString(),
                        style: TextStyle(
                          color: foreground,
                        )),
                  ))
              .toList(),
          onChanged: ((val) {
            if (val is T && onChange is Function) {
              onChange!(val);
            }
          }),
        ),
      ),
    );
  }
}
