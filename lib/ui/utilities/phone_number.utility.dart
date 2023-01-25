abstract class PhoneNumberUtility {
  static String toCallNumber(String value) {
    return value.replaceAll(RegExp('\\W+'), '').trim();
  }

  static String toAppNumber(String value) {
    var number = toCallNumber(value);
    if (number.length > 10) {
      number = number.substring(2, 12);
    }
    return "${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6, 10)}";
  }

  static bool isNumberPhone(String value) {
    var number = toCallNumber(value);

    try {
      double.parse(number);
      return true;
    } catch (e) {
      return false;
    }
  }
}
