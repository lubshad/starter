import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime? {
  String? get odooDateFormat =>
      this == null ? null : DateFormat("yyyy-MM-dd").format(this!);
  String? get dateTimeFormat =>
      this == null ? null : DateFormat("E, MMM, d, y, hh:mm aa").format(this!);

  String? get timeFormat =>
      this == null ? null : DateFormat("hh:mm aa").format(this!);

  String? get dateFormat {
    if (this == null) return null;

    DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    int daysDifference =
        today.difference(this!.copyWith(hour: 0, minute: 0, second: 0)).inDays;
    if (daysDifference == 1) {
      return "Yesterday";
    }
    if (daysDifference == -1) {
      return "Tomorrow";
    }
    if (daysDifference == 0) {
      return "Today";
    }
    return DateFormat("E, MMM, d, y").format(this!);
  }
}
