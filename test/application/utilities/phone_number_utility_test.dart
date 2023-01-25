import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phone number utility test', () {
    test("format to call number", () {
      var test = "123-456-7890";
      var result = PhoneNumberUtility.toCallNumber(test);
      expect(result, isA<String>());
      expect(result, "1234567890");
    });
  });
}
