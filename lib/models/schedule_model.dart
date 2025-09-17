class ScheduleModel {
  final String type; // one_time, weekly, monthly
  final String startDate; // yyyy-MM-dd
  final bool indefinite;
  final String? oneTimeStart;
  final String? oneTimeEnd;
  final int? interval; // for weekly/monthly recurrences
  final List<String>? windows; // days of week (Mon, Tue, etc.)

  ScheduleModel({
    required this.type,
    required this.startDate,
    required this.indefinite,
    this.oneTimeStart,
    this.oneTimeEnd,
    this.interval,
    this.windows,
  });

  Map<String, dynamic> toJson() => {
    "type": type,
    "start_date": startDate,
    "indefinite": indefinite,
    if (oneTimeStart != null) "one_time_start": oneTimeStart,
    if (oneTimeEnd != null) "one_time_end": oneTimeEnd,
    if (interval != null) "interval": interval,
    if (windows != null) "windows": windows,
  };
}
