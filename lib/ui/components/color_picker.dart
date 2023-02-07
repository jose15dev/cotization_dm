import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final double width;
  final Color? initialColor;
  final Function(Color, Color) onChange;
  const ColorPicker(
      {super.key,
      required this.onChange,
      required this.width,
      this.initialColor});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _bgColor, _fgColor;
  late double _position;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    var index = BgFgColorUtility.getIndex(
        widget.initialColor ?? Colors.primaries.first);
    if (index == -1) {
      _position = 0.0;
    } else {
      _position = (index / (Colors.primaries.length - 1) * widget.width);
    }

    _bgColor = _getSliderColor(_position);
    _fgColor = ColorPalete.white;
  }

  void _selectColor(double value) {
    if (value < widget.width) {
      _position = value;
    }
    if (value > widget.width) {
      _position = widget.width;
    }
    if (value < 0) {
      _position = 0;
    }
    setState(() {
      _bgColor = _getSliderColor(_position);
      _fgColor = BgFgColorUtility.getFgForBg(_bgColor.value);
      widget.onChange(_bgColor, _fgColor);
    });
  }

  Color _getSliderColor(double position) {
    var value =
        (position / widget.width * (Colors.primaries.length - 1)).floor();
    return Colors.primaries[value];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: ((details) {
        _selectColor(details.localPosition.dx);
      }),
      onHorizontalDragUpdate: (details) {
        _selectColor(details.localPosition.dx);
      },
      onTapDown: ((details) {
        _selectColor(details.localPosition.dx);
      }),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          child: Container(
            width: widget.width,
            height: 7,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(colors: Colors.primaries),
            ),
            child: CustomPaint(
              painter: _SliderIndicatorPainter(_position, _bgColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final Color color;
  _SliderIndicatorPainter(this.position, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(position, size.height / 2),
      12,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}
