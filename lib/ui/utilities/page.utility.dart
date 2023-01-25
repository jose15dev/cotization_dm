import 'package:flutter/material.dart';

SliverToBoxAdapter get spacer {
  return const SliverToBoxAdapter(
    child: SizedBox(
      height: 20,
    ),
  );
}

Widget heading(String data, [Function()? onPressed, String label = "Ver mas"]) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        data,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
      if (onPressed is Function)
        TextButton(onPressed: onPressed, child: Text(label))
    ],
  );
}

SliverToBoxAdapter customPadding(Widget child,
    [double paddingY = 0, double padddingX = 20.0]) {
  return SliverToBoxAdapter(
      child: Padding(
    padding: EdgeInsets.symmetric(horizontal: padddingX, vertical: paddingY),
    child: child,
  ));
}
