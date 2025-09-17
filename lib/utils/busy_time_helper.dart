import 'package:flutter/material.dart';

class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeOfDayRange({required this.start, required this.end});
}

class BusyTimeHelper {
  // busyRanges is normalized recurring, keyed by weekday
  static bool isHourBusy(
    int weekday,
    TimeOfDay candidate,
    Map<int, List<TimeOfDayRange>> busyRanges,
  ) {
    if (!busyRanges.containsKey(weekday)) return false;

    for (final range in busyRanges[weekday]!) {
      final startMinutes = range.start.hour * 60 + range.start.minute;
      final endMinutes = range.end.hour * 60 + range.end.minute;
      final candidateMinutes = candidate.hour * 60 + candidate.minute;

      if (candidateMinutes >= startMinutes && candidateMinutes < endMinutes) {
        return true;
      }
    }
    return false;
  }

  /// Groups busy times into weekly buckets (1=Mon ... 7=Sun).
  static Map<int, List<TimeOfDayRange>> normalize(
    List<DateTimeRange> busyTimes,
  ) {
    final Map<int, List<TimeOfDayRange>> weekly = {};
    for (final range in busyTimes) {
      final weekday = range.start.weekday;
      weekly.putIfAbsent(weekday, () => []);
      weekly[weekday]!.add(
        TimeOfDayRange(
          start: TimeOfDay.fromDateTime(range.start),
          end: TimeOfDay.fromDateTime(range.end),
        ),
      );
    }
    return weekly;
  }

  /// Returns true if provider busy times look like a weekly recurring pattern.
  static bool looksRecurring(List<DateTimeRange> busyTimes) {
    final grouped = <String, int>{};
    for (final r in busyTimes) {
      final key = '${r.start.weekday}-${r.start.hour}-${r.end.hour}';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }
    return grouped.values.any((count) => count >= 3);
  }

  /// Returns exceptions (conflicts with specific dates)
  static List<DateTimeRange> detectExceptions(List<DateTimeRange> busyTimes) {
    if (looksRecurring(busyTimes)) return [];
    return busyTimes;
  }
}
