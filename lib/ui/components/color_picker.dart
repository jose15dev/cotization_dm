import 'package:cotizacion_dm/ui/utilities/theme_utility.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final int crossAxisCount;
  final Function(Color, Color) onChange;
  const ColorPicker(
      {super.key, required this.crossAxisCount, required this.onChange});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color bgColor, fgColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bgColor = Colors.primaries.first;
    fgColor = ColorPalete.white;
  }

  void _selectColor(Color color, int index) {
    setState(() {
      bgColor = color;
      fgColor = BgFgColorUtility.getFgForBg(color.value);
      widget.onChange(bgColor, fgColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
        ),
        itemCount: Colors.primaries.length,
        itemBuilder: ((context, index) {
          var color = Colors.primaries[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: GestureDetector(
              onTap: () => _selectColor(color, index),
              child: CircleAvatar(
                backgroundColor: color,
              ),
            ),
          );
        }));
  }
}
