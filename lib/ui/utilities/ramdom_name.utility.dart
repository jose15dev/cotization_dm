import 'dart:math';
import 'dart:convert';

abstract class RamdomNameUtility {
  static String getRandString(String name) {
    int len = 10;
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return "${base64UrlEncode(values)}-$name";
  }
}
