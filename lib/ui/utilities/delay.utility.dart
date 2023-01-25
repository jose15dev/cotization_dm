abstract class DelayUtility {
  static Future<void> delay() {
    return Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> custom(int seconds) {
    return Future.delayed(Duration(seconds: seconds));
  }
}
