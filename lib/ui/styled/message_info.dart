import 'package:flutter/material.dart';

class MessageInfo extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color? foreground;
  final IconData? icon;
  final bool enableIcon;
  const MessageInfo(
    this.text, {
    Key? key,
    this.onTap,
    this.icon,
    this.enableIcon = true,
    this.foreground,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = foreground ?? Colors.grey.shade600;
    const padding = 20.0;
    return SizedBox(
      width: 200,
      height: 200,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(padding),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (() {
                    if (enableIcon) {
                      return Icon(
                        icon ?? Icons.refresh,
                        color: color,
                        size: 40.0,
                      );
                    }
                    return Container();
                  })(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
