import 'dart:convert';

import 'package:cotizacion_dm/shared/utilities/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Encrypt String Test", () {
    var testStr = "Test";
    test("Encrypt String", () {
      var encrypted = encryptString(testStr);
      expect(encrypted, isA<String>());
    });

    test("Decrypt String", () {
      var encrypted = encryptString(testStr);
      var decrypted = decryptString(encrypted);
      expect(testStr, decrypted);
    });
  });

  group("Encrypt JSON Test", () {
    var map = {
      "name": "Test",
      "description": "Test",
    };
    test("Encrypt JSON", () {
      var json = jsonEncode(map);
      var encrypted = encryptString(json);
      expect(encrypted, isA<String>());
    });

    test("Decrypt JSON", () {
      var json = jsonEncode(map);
      var encrypted = encryptString(json);
      expect(encrypted, isA<String>());
      var decrypted = decryptString(encrypted);
      expect(decrypted, json);
      var mapDecrypted = jsonDecode(decrypted);
      expect(mapDecrypted, map);
    });
  });
}
