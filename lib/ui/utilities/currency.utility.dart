import 'package:intl/intl.dart';

class CurrencyUtility {
  static final _currencyFormat =
      NumberFormat.simpleCurrency(locale: "en_US", decimalDigits: 0);
  static String doubleToCurrency(double number) {
    return _currencyFormat.format(number);
  }

  static String doubleToCurrencyWithOutDollarSign(double number) {
    return NumberFormat.currency(locale: "en_US", decimalDigits: 0, symbol: "")
        .format(number);
  }

  static double currencyToDouble(String currency) {
    return _currencyFormat.parse(currency).toDouble();
  }
}
