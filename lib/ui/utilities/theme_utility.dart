import 'package:cotizacion_dm/globals.dart';
import 'package:flutter/material.dart';

abstract class ColorPalete {
  static Color get black => const Color.fromARGB(255, 0, 0, 0);
  static Color get primary => const Color.fromARGB(255, 104, 114, 255);
  static Color get secondary => const Color.fromARGB(255, 203, 207, 255);
  static Color get white => const Color.fromARGB(255, 255, 246, 237);
  static Color get success => const Color.fromARGB(255, 30, 175, 107);
  static Color get error => const Color.fromARGB(255, 255, 90, 78);
}

abstract class ThemeUtility {
  static get light {
    return ThemeData(
      // fontFamily: fontFamily,
      scaffoldBackgroundColor: ColorPalete.white,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          size: 30,
        ),
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ColorPalete.black,
          fontSize: 30,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorPalete.white,
        iconSize: 32.5,
        foregroundColor: ColorPalete.primary,
      ),
    );
  }
}
