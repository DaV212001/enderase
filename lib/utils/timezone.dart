/// Simple timezone helper for Africa/Addis_Ababa (UTC+3, no DST)
/// This keeps internal calculations consistent in "app zone" wall time.

import 'package:flutter/material.dart';

class AppTimeZone {
  static const int offsetHours = 3; // Africa/Addis_Ababa UTC+3

  /// Convert a UTC DateTime to app-zone wall time (no timezone attached)
  static DateTime utcToAppZone(DateTime dtUtc) {
    final u = dtUtc.toUtc();
    return DateTime(
      u.year,
      u.month,
      u.day,
      u.hour,
      u.minute,
      u.second,
      u.millisecond,
      u.microsecond,
    ).add(const Duration(hours: offsetHours));
  }

  /// Convert an app-zone wall time DateTime to UTC for API submission
  static DateTime appZoneToUtc(DateTime appLocal) {
    return DateTime(
      appLocal.year,
      appLocal.month,
      appLocal.day,
      appLocal.hour,
      appLocal.minute,
      appLocal.second,
      appLocal.millisecond,
      appLocal.microsecond,
    ).subtract(const Duration(hours: offsetHours)).toUtc();
  }

  /// Convert a DateTimeRange defined in UTC to app-zone wall time
  static DateTimeRange rangeUtcToAppZone(DateTimeRange r) {
    return DateTimeRange(
      start: utcToAppZone(r.start),
      end: utcToAppZone(r.end),
    );
  }
}


