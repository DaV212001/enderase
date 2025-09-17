import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleValidationHelper {
  // ---------- Validation helpers (put inside ScheduleController) ----------

  int _minutesFromString(String s) {
    final parts = s.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToString(int t) {
    final h = (t ~/ 60) % 24;
    final m = t % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Return true if [aStart,aEnd) overlaps [bStart,bEnd) on a 24h circle.
  /// Handles wrap-around (end <= start).
  bool _intervalsOverlap(int aStart, int aEnd, int bStart, int bEnd) {
    List<List<int>> segA = (aStart <= aEnd)
        ? [
            [aStart, aEnd],
          ]
        : [
            [aStart, 1440],
            [0, aEnd],
          ];
    List<List<int>> segB = (bStart <= bEnd)
        ? [
            [bStart, bEnd],
          ]
        : [
            [bStart, 1440],
            [0, bEnd],
          ];

    for (final sa in segA) {
      for (final sb in segB) {
        final a0 = sa[0], a1 = sa[1], b0 = sb[0], b1 = sb[1];
        if (!(a1 <= b0 || a0 >= b1)) return true;
      }
    }
    return false;
  }

  /// Expand provider busy DateTimeRange entries into minute intervals for the given weekday.
  /// Weekday: 1=Mon, ... 7=Sun
  List<Map<String, int>> busyIntervalsForWeekday(
    int weekday,
    List<DateTimeRange<DateTime>> providerBusyTimes,
  ) {
    final List<Map<String, int>> out = [];
    for (final slot in providerBusyTimes) {
      // iterate days that slot touches; restrict to same-day portion
      DateTime cur = DateTime(
        slot.start.year,
        slot.start.month,
        slot.start.day,
      );
      final last = DateTime(slot.end.year, slot.end.month, slot.end.day);
      while (!cur.isAfter(last)) {
        if (cur.weekday == weekday) {
          final dayStart = DateTime(cur.year, cur.month, cur.day);
          final dayEnd = DateTime(cur.year, cur.month, cur.day, 23, 59, 59);

          final sDt = slot.start.isBefore(dayStart) ? dayStart : slot.start;
          final eDt = slot.end.isAfter(dayEnd)
              ? dayEnd.add(const Duration(seconds: 1))
              : slot.end;

          final sMin = sDt.hour * 60 + sDt.minute;
          final eMin = eDt.hour * 60 + eDt.minute;
          if (sMin != eMin) out.add({'start': sMin, 'end': eMin});
        }
        cur = cur.add(const Duration(days: 1));
      }
    }
    return out;
  }

  /// Validate a candidate window for [weekday].
  /// Returns null if OK, otherwise returns a human-readable error string.
  String? validateWindow({
    required int weekday,
    required String start, // "HH:mm"
    required String end, // "HH:mm"
    int? indexToIgnore, // when editing an existing window, ignore this index
    required List<DateTimeRange<DateTime>> providerBusyTimes,
    required Map<String, List<Map<String, String>>> windows,
  }) {
    final allWindows = windows;
    // basic format/parse
    final r = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$');
    if (!r.hasMatch(start) || !r.hasMatch(end)) return 'Time must be HH:mm';

    final sMin = _minutesFromString(start);
    final eMin = _minutesFromString(end);
    if (sMin == eMin) return 'Start and end cannot be identical';

    // check provider busy intervals for that weekday
    final busy = busyIntervalsForWeekday(weekday, providerBusyTimes);
    for (final b in busy) {
      final bS = b['start']!, bE = b['end']!;
      if (_intervalsOverlap(sMin, eMin, bS, bE)) {
        return 'Conflicts with provider busy time: ${_minutesToString(bS)}–${_minutesToString(bE)}';
      }
    }

    // check other windows for the same weekday
    final existing = allWindows[weekday.toString()] ?? [];
    for (int i = 0; i < existing.length; i++) {
      if (indexToIgnore != null && i == indexToIgnore) continue;
      final ex = existing[i];
      final exS = _minutesFromString(ex['start']!);
      final exE = _minutesFromString(ex['end']!);
      if (_intervalsOverlap(sMin, eMin, exS, exE)) {
        return 'Overlaps existing window ${ex['start']}-${ex['end']}';
      }
    }

    return null; // ok
  }

  /// Validate all windows before submit; returns first error string or null
  String? validateAllWindows(
    List<DateTimeRange<DateTime>> providerBusyTimes,
    Map<String, List<Map<String, String>>> windows,
  ) {
    for (final entry in windows.entries) {
      final weekday = entry.key;
      final list = entry.value;
      for (int i = 0; i < list.length; i++) {
        final w = list[i];
        final err = validateWindow(
          weekday: int.parse(weekday),
          start: w['start']!,
          end: w['end']!,
          indexToIgnore: i,
          providerBusyTimes: providerBusyTimes,
          windows: windows,
        );
        if (err != null) {
          return 'Day ${DateFormat('EEEE').format(DateTime(2025, 9, int.parse(weekday)))}: $err';
        }
      }
    }
    return null;
  }
}
