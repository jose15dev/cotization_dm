import 'package:cotizacion_dm/ui/utilities/currency.utility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Currency format state", () {
    test("check if format works", () {
      double value = 3000;
      var currency = CurrencyUtility.doubleToCurrency(value);
      expect(currency, isA<String>());
      expect(currency, "\$3,000");
    });

    test("check if parse works", () {
      String currency = "\$3,000";

      var value = CurrencyUtility.currencyToDouble(currency);
      expect(value, isA<double>());
      expect(value, 3000.0);
    });
  });
}
