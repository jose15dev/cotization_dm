import 'package:intl/intl.dart';

class CurrencyUtility {
  static final _currencyFormat =
      NumberFormat.simpleCurrency(locale: "en_US", decimalDigits: 0);
  static String doubleToCurrency(double number) {
    return _currencyFormat.format(number);
  }

  static double currencyToDouble(String currency) {
    return _currencyFormat.parse(currency).toDouble();
  }
}
