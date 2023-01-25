import "package:timeago/timeago.dart" as timeago;

abstract class TimeAgoUtility {
  static String toTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: "es");
  }

  static String toTimeAgoShort(DateTime dateTime) {
    return timeago.format(dateTime, locale: "es_short");
  }
}
