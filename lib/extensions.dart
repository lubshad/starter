import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'core/logger.dart';
import 'core/repository.dart';
import 'services/shared_preferences_services.dart';

extension MapExtension on Map {
  void clearFields() {
    removeWhere((key, value) => value == "" || value == null || value == []);
  }
}

extension DateTimeExtension on DateTime? {
  bool isSameDay(DateTime value) {
    return this?.day == value.day &&
        this?.month == value.month &&
        this?.year == value.year;
  }

  bool get isToday {
    DateTime now = serverUtcTime;
    return this?.day == now.day &&
        this?.month == now.month &&
        this?.year == now.year;
  }

  bool get isYesterday {
    DateTime now = serverUtcTime;
    return this?.day == now.day - 1 &&
        this?.month == now.month &&
        this?.year == now.year;
  }

  String? get odooDateFormat =>
      this == null ? null : DateFormat("yyyy-MM-dd").format(this!);
  String? get dateTimeFormat =>
      this == null ? null : DateFormat("E, MMM, d, y, hh:mm aa").format(this!);
  String? get timeFormat =>
      this == null ? null : DateFormat("hh:mm aa").format(this!);
  String? dateFormat({bool year = true}) {
    if (this == null) return null;
    DateTime today = serverUtcTime.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    int daysDifference = today
        .difference(
          this!.copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
        )
        .inDays;
    if (daysDifference == 1) {
      return "Yesterday";
    }
    if (daysDifference == -1) {
      return "Tomorrow";
    }
    if (daysDifference == 0) {
      return "Today";
    }
    if (year) {
      return DateFormat("E, MMM, d, y").format(this!);
    }
    return DateFormat("E, MMM, d").format(this!);
  }

  TimeOfDay get timeofday =>
      TimeOfDay(hour: this?.hour ?? 0, minute: this?.minute ?? 0);

  num get number => (this?.hour ?? 0) + ((this?.minute ?? 0) / 60);
}

extension DurationExtension on Duration {
  String get toHoursMinutesSeconds {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours.remainder(24));
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get toHoursMinutes {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours.remainder(24));
    final minutes = twoDigits(inMinutes.remainder(60));

    if (hours == "00") return "$minutes m";
    return "$hours h $minutes m";
  }

  String get toMinuteSeconds {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    if (minutes == "00") return "$seconds s";
    return "$minutes m $minutes s";
  }
}

extension ResponseExtension on Response {
  String get message => data["message"] ?? "";
}

extension DoubleExtension on double {
  double get mphToKph => this / 36;
  int get alpha => (this * 255).toInt();
}

Future<bool> initializeUTCTime() async {
  await DataRepository.i
      .serverTime()
      .then((value) async {
        DateTime now = DateTime.now();
        await SharedPreferencesService.i.setValue(
          key: serverTimeDifferenceKey,
          value: now.toUtc().difference(value.toUtc()).inSeconds.toString(),
        );
      })
      .onError((error, stackTrace) {
        logError(error);
      });
  return true;
}

DateTime get serverUtcTime {
  if (serverTimeDifferenceString.isEmpty) {
    return DateTime.now();
  } else {
    return DateTime.now().subtract(
      Duration(seconds: int.parse(serverTimeDifferenceString)),
    );
  }
}

extension NumberExtension on num {
  DateTime get dateTime {
    return DateTime(2000, 1, 1, toInt(), ((this - toInt()) * 60).toInt());
  }

  String get currency => NumberFormat.currency(symbol: "SR ").format(this);
  String get symbol => isNegative ? "-" : "+";
}
