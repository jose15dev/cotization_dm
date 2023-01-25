import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  const TitleBar({
    required this.title,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var headline32 = Theme.of(context).textTheme.headline3;
    return SizedBox(
      width: size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomBackButton(
            onTap: onTap,
          ),
          SizedBox(
            width: size.width * 0.5,
            child: Text(
              title,
              style: headline32,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
