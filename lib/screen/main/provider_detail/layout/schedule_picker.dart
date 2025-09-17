import 'package:enderase/utils/schedule_validation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../setup_files/templates/dio_template.dart';
import '../../../../utils/busy_time_helper.dart';
import '../../../../widgets/circular_time_wheel.dart';
import 'booking_form.dart';

bool isDaySelectable(DateTime date, List<DateTimeRange> busyTimes) {
  if (busyTimes.isEmpty) return true;

  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  // Day is blocked only if a busy slot fully covers it
  final isFullDayBusy = busyTimes.any((slot) {
    return slot.start.isBefore(startOfDay) && slot.end.isAfter(endOfDay);
  });

  return !isFullDayBusy;
}

/// Checks if a specific moment is inside any busy slot
bool isDateTimeFree(DateTime dateTime, List<DateTimeRange> busyTimes) {
  if (busyTimes.isEmpty) return true;

  return !busyTimes.any(
    (slot) => dateTime.isAfter(slot.start) && dateTime.isBefore(slot.end),
  );
}

/// Controller to manage booking schedules
class ScheduleController extends GetxController {
  // ---------- Validation helpers (put inside ScheduleController) ----------
  ScheduleValidationHelper scheduleValidationHelper =
      ScheduleValidationHelper();
  String? validateWindow({
    required int weekday,
    required String start, // "HH:mm"
    required String end, // "HH:mm"
    Map<int, List<Map<String, String>>>?
    candidateWindows, // default to controller.windows
    int? indexToIgnore, // when editing an existing window, ignore this index
  }) {
    return scheduleValidationHelper.validateWindow(
      weekday: weekday,
      start: start,
      end: end,
      providerBusyTimes: providerBusyTimes,
      windows: windows,
    );
  }

  var bookingType = 'one_time'.obs; // one_time | recurring | full_time
  /// Checks if a given date is fully free (day-level) or partially blocked

  // Dates
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  var indefinite = false.obs;

  // One-time specific
  Rx<DateTime?> oneTimeStart = Rx<DateTime?>(null);
  Rx<DateTime?> oneTimeEnd = Rx<DateTime?>(null);

  // Recurring / Full-time specifics
  var frequency = 'weekly'.obs; // weekly, monthly, etc.
  var interval = 1.obs; // Default to 1 (every week/month)

  /// weekday windows: 1=Mon ... 7=Sun
  var windows = <String, List<Map<String, String>>>{}.obs;
  var providerBusyTimes = <DateTimeRange>[].obs;
  var isLoading = false.obs;

  // Holds normalized recurring busy windows (hard blocks)
  final disabledWeeklyBusy = <int, List<TimeOfDayRange>>{}.obs;

  // Holds specific date-bound busy slots (soft warnings)
  final exceptionBusy = <DateTimeRange>[].obs;

  void processProviderBusyTimes(List<DateTimeRange> providerBusyTimes) {
    if (BusyTimeHelper.looksRecurring(providerBusyTimes)) {
      disabledWeeklyBusy.value = BusyTimeHelper.normalize(providerBusyTimes);
      Logger().d(disabledWeeklyBusy);
      exceptionBusy.clear();
    } else {
      disabledWeeklyBusy.clear();
      exceptionBusy.assignAll(
        BusyTimeHelper.detectExceptions(providerBusyTimes),
      );
      Logger().d(exceptionBusy);
    }
  }

  Future<void> fetchProviderAvailability(
    int providerId, {
    DateTime? startDate,
    int days = 16,
  }) async {
    try {
      isLoading.value = true;
      await DioService.dioGet(
        path: '/api/v1/client/booking/get-times/$providerId?days=31',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now()),
          'days': days,
        },
        onSuccess: (response) {
          Logger().d(response.data);
          final data = response.data['data'];
          if (data != null) {
            final times = data['times'] as Map<String, dynamic>;
            providerBusyTimes.clear();

            times.forEach((dateStr, dateData) {
              final busyList = dateData['busy'] as List;
              for (var busy in busyList) {
                final start = DateTime.parse(busy['start']).toLocal();
                final end = DateTime.parse(busy['end']).toLocal();
                providerBusyTimes.add(DateTimeRange(start: start, end: end));
              }
            });
            Logger().d(providerBusyTimes);
            processProviderBusyTimes(providerBusyTimes);
          }
        },
        onFailure: (error, response) {
          Get.snackbar('Error', 'Failed to fetch provider availability');
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Sync with BookingController ----------------
  void _bindToBookingController(BookingController bookingCtrl) {
    // Watch all relevant fields and rebuild payload reactively
    everAll(
      [
        bookingType,
        startDate,
        endDate,
        indefinite,
        oneTimeStart,
        oneTimeEnd,
        frequency,
        interval,
        windows,
      ],
      (_) {
        bookingCtrl.updatePayload(
          providerIdReceived: providerId,
          categoryIdReceived: bookingCtrl.selectedCategory.value?.id,
          bookingTypeReceived: bookingType.value,
          startDateReceived: startDate.value,
          endDateReceived: endDate.value,
          indefiniteReceived: indefinite.value,
          oneTimeStartReceived: oneTimeStart.value,
          oneTimeEndReceived: oneTimeEnd.value,
          frequencyReceived: frequency.value,
          intervalReceived: interval.value,
          windowsReceived: windows.value,
        );
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchProviderAvailability(providerId);
    final bookingCtrl = Get.find<BookingController>(
      tag: providerId.toString(),
    ); // providerId=1
    _bindToBookingController(bookingCtrl);
    // Set default windows for full_time when booking type changes
    ever(bookingType, (type) {
      if (type == 'full_time') {
        // Set all weekdays with default working hours
        windows.clear();
        for (int i = 1; i <= 7; i++) {
          windows[i.toString()] = [
            {"start": "09:00", "end": "17:00"},
          ];
        }
      } else if (type == 'one_time' || type == 'recurring') {
        // Clear windows for one-time bookings
        windows.clear();
      }
      update();
    });
  }

  void toggleDay(int weekday, {String start = "09:00", String end = "17:00"}) {
    if (windows.containsKey(weekday.toString())) {
      windows.remove(weekday.toString());
    } else {
      windows[weekday.toString()] = [
        {"start": start, "end": end},
      ];
    }
    update();
  }

  var isProblematic = false.obs;
  Rx<TimeOfDay?> tempPicked = Rx<TimeOfDay?>(null);

  /// Show a date picker then a time picker for one-time booking start
  Future<void> selectOneTimeStart(BuildContext context) async {
    // Step 1: Pick a date with full vs partial indication
    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          height: 400,
          child: SfCalendar(
            minDate: DateTime.now(),
            view: CalendarView.month,
            blackoutDates: providerBusyTimes
                .where(
                  (slot) =>
                      slot.start.hour == 0 &&
                      slot.end.difference(slot.start).inHours >= 24,
                )
                .map(
                  (slot) => DateTime(
                    slot.start.year,
                    slot.start.month,
                    slot.start.day,
                  ),
                )
                .toList(),
            monthViewSettings: const MonthViewSettings(
              showTrailingAndLeadingDates: true,
            ),
            monthCellBuilder: (context, details) {
              final day = details.date;

              final isFullyBlocked =
                  providerBusyTimes.any(
                    (slot) =>
                        slot.start.year == day.year &&
                        slot.start.month == day.month &&
                        slot.start.day == day.day &&
                        slot.start.hour == 0 &&
                        slot.end.difference(slot.start).inHours >= 24,
                  ) ||
                  day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  );

              final isPartiallyBlocked =
                  !isFullyBlocked &&
                  providerBusyTimes.any(
                    (slot) =>
                        slot.start.year == day.year &&
                        slot.start.month == day.month &&
                        slot.start.day == day.day,
                  );

              if (isFullyBlocked) {
                return _buildDayCell(
                  day,
                  Colors.grey.withValues(alpha: 0.4),
                  Colors.black38,
                );
              } else if (isPartiallyBlocked) {
                return _buildDayCell(
                  day,
                  Colors.orange.withValues(alpha: 0.3),
                  Colors.black,
                );
              }
              return _buildDayCell(day, null, Colors.black);
            },
            onTap: (details) {
              if (details.date != null &&
                  isDaySelectable(details.date!, providerBusyTimes)) {
                Navigator.pop(context, details.date);
              }
            },
            specialRegions: providerBusyTimes
                .map(
                  (r) => TimeRegion(
                    startTime: r.start,
                    endTime: r.end,
                    enablePointerInteraction: false,
                    color: Colors.red.withValues(alpha: 0.2),
                    text: 'Busy',
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    if (pickedDate == null) return;

    // Step 2 — Build all busy ranges that overlap the picked date.
    final dayStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );
    final dayEnd = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      23,
      59,
      59,
    );

    final busyForDay = providerBusyTimes.where((slot) {
      return !(slot.end.isBefore(dayStart) || slot.start.isAfter(dayEnd));
    }).toList();

    // Step 3 — Show a time picker for one-time booking start
    DateTime? pickedDateTime;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 360,
          height: 560,
          child: FlexibleTimeSelector(
            baseDate: pickedDate,
            busyRanges: busyForDay,
            initiallyUse24Hour: true, // start with 24h mode
            onValidSelected: (dt) {
              pickedDateTime = dt;
            },
          ),
        ),
      ),
    );

    if (pickedDateTime == null) return;

    // Step 4 — validate vs oneTimeEnd
    if (oneTimeEnd.value != null &&
        oneTimeEnd.value!.isBefore(pickedDateTime!)) {
      Get.snackbar(
        'Error',
        'Start time cannot be after end time',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return;
    }
    oneTimeStart.value = pickedDateTime!;
    update();
  }

  Widget _buildDayCell(DateTime day, Color? bgColor, Color textColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Text('${day.day}', style: TextStyle(color: textColor)),
    );
  }

  /// Show a date picker then a time picker for one-time booking end
  Future<void> selectOneTimeEnd(BuildContext context) async {
    // Use start time + 1 hour as initial date/time if start is set
    // final initialDate =
    //     oneTimeStart.value?.add(const Duration(hours: 1)) ?? DateTime.now();

    final pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          height: 400,
          child: SfCalendar(
            view: CalendarView.month,
            minDate: DateTime.now(),
            blackoutDates: providerBusyTimes
                .where(
                  (slot) =>
                      slot.start.hour == 0 &&
                      slot.end.difference(slot.start).inHours >= 24,
                )
                .map(
                  (slot) => DateTime(
                    slot.start.year,
                    slot.start.month,
                    slot.start.day,
                  ),
                )
                .toList(),
            monthViewSettings: const MonthViewSettings(
              showTrailingAndLeadingDates: true,
            ),
            monthCellBuilder: (context, details) {
              final day = details.date;

              final isFullyBlocked =
                  providerBusyTimes.any(
                    (slot) =>
                        slot.start.year == day.year &&
                        slot.start.month == day.month &&
                        slot.start.day == day.day &&
                        slot.start.hour == 0 &&
                        slot.end.difference(slot.start).inHours >= 24,
                  ) ||
                  day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  );

              final isPartiallyBlocked =
                  !isFullyBlocked &&
                  providerBusyTimes.any(
                    (slot) =>
                        slot.start.year == day.year &&
                        slot.start.month == day.month &&
                        slot.start.day == day.day,
                  );

              if (isFullyBlocked) {
                return _buildDayCell(
                  day,
                  Colors.grey.withValues(alpha: 0.4),
                  Colors.black38,
                );
              } else if (isPartiallyBlocked) {
                return _buildDayCell(
                  day,
                  Colors.orange.withValues(alpha: 0.3),
                  Colors.black,
                );
              }
              return _buildDayCell(day, null, Colors.black);
            },
            onTap: (details) {
              if (details.date != null &&
                  isDaySelectable(details.date!, providerBusyTimes)) {
                Navigator.pop(context, details.date);
              }
            },
            specialRegions: providerBusyTimes
                .map(
                  (r) => TimeRegion(
                    startTime: r.start,
                    endTime: r.end,
                    enablePointerInteraction: false,
                    color: Colors.red.withValues(alpha: 0.2),
                    text: 'Busy',
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    if (pickedDate == null) return;

    final dayStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );
    final dayEnd = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      23,
      59,
      59,
    );

    final busyForDay = providerBusyTimes.where((slot) {
      return !(slot.end.isBefore(dayStart) || slot.start.isAfter(dayEnd));
    }).toList();

    DateTime? pickedTime;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 360,
          height: 560,
          child: FlexibleTimeSelector(
            baseDate: pickedDate,
            busyRanges: busyForDay,
            initiallyUse24Hour: true, // start with 24h mode
            onValidSelected: (dt) {
              pickedTime = dt;
            },
          ),
        ),
      ),
    );

    if (pickedTime == null) return;

    final proposedEnd = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime!.hour,
      pickedTime!.minute,
    );

    // ⛔ Block if proposed end falls inside a busy range
    // final overlapsBusy = isDateTimeFree(proposedEnd, providerBusyTimes);
    //
    // if (overlapsBusy) {
    //   Get.snackbar(
    //     'Error',
    //     'Selected end time falls into a busy slot',
    //     colorText: Colors.white,
    //     backgroundColor: Colors.red,
    //   );
    //   return;
    // }

    oneTimeEnd.value = proposedEnd;

    // If end time is before start time, reject it
    if (oneTimeStart.value != null &&
        oneTimeEnd.value!.isBefore(oneTimeStart.value!)) {
      Get.snackbar(
        'Error',
        'End time cannot be before start time',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      oneTimeEnd.value = null;
    }

    update();
  }

  Map<String, dynamic> buildPayload({
    required int providerId,
    required int categoryId,
  }) {
    final payload = {
      "provider_id": providerId,
      "category_id": categoryId,
      "timezone": "Africa/Addis_Ababa",
    };

    if (bookingType.value == 'one_time') {
      if (oneTimeStart.value != null) {
        payload["start_date"] = DateFormat(
          "yyyy-MM-dd",
        ).format(oneTimeStart.value!);
      }

      payload["schedule"] = {
        "type": "one_time",
        "one_time_start": oneTimeStart.value?.toIso8601String(),
        "one_time_end": oneTimeEnd.value?.toIso8601String(),
      };
    } else {
      if (startDate.value != null) {
        payload["start_date"] = DateFormat(
          "yyyy-MM-dd",
        ).format(startDate.value!);
      }
      if (indefinite.value) {
        payload["indefinite"] = true;
      } else if (endDate.value != null) {
        payload["end_date"] = DateFormat("yyyy-MM-dd").format(endDate.value!);
      }

      payload["schedule"] = {
        "type": bookingType.value,
        "frequency": frequency.value,
        "interval": interval.value,
        "windows": windows,
      };
    }

    return payload;
  }

  final int providerId;
  ScheduleController({required this.providerId});
}

class SchedulePicker extends StatelessWidget {
  final ScheduleController controller;

  final int providerId;
  final int categoryId;
  final Function(Map<String, dynamic>) onFinalize;

  SchedulePicker({
    super.key,
    required this.providerId,
    required this.categoryId,
    required this.onFinalize,
  }) : controller = Get.put(ScheduleController(providerId: providerId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking type selector
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildBookingTypeOption(
                            context,
                            "One-Time",
                            'one_time',
                            Icons.calendar_today,
                          ),
                        ),
                        Expanded(
                          child: _buildBookingTypeOption(
                            context,
                            "Recurring",
                            'recurring',
                            Icons.repeat,
                          ),
                        ),
                        Expanded(
                          child: _buildBookingTypeOption(
                            context,
                            "Full-Time",
                            'full_time',
                            Icons.work,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.bookingType.value != 'one_time')
                  const SizedBox(height: 20),

                // Date range selection for recurring/full-time
                // if (controller.bookingType.value != 'one_time')
                //   _buildSectionHeader("Date Range"),
                if (controller.bookingType.value != 'one_time')
                  Card(
                    color: Theme.of(context).cardColor,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Obx(
                            () => _buildDatePickerField(
                              context,
                              label: "Start Date",
                              value: controller.startDate.value,
                              onTap: () =>
                                  _selectDate(context, isStartDate: true),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => controller.indefinite.value
                                ? Row(
                                    children: [
                                      const Text("Indefinite"),
                                      const Spacer(),
                                      Switch(
                                        value: controller.indefinite.value,
                                        onChanged: (v) =>
                                            controller.indefinite.value = v,
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Obx(
                                        () => _buildDatePickerField(
                                          context,
                                          label: "End Date",
                                          value: controller.endDate.value,
                                          onTap: () => _selectDate(
                                            context,
                                            isStartDate: false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (controller.bookingType.value !=
                                          'one_time')
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () =>
                                                controller.indefinite.value =
                                                    true,
                                            icon: Icon(Ionicons.infinite),
                                            label: const Text(
                                              "Set as indefinite",
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                if (controller.bookingType.value == 'one_time')
                  _buildOneTimeSection(context),
                if (controller.bookingType.value != 'one_time')
                  _buildRecurringFullTimeSection(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Widget _buildSectionHeader(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8.0),
  //     child: Text(
  //       title,
  //       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     ),
  //   );
  // }

  Widget _buildBookingTypeOption(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = controller.bookingType.value == value;
    return GestureDetector(
      onTap: () => controller.bookingType.value = value,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(value == 'one_time' ? 8 : 0),
            topRight: Radius.circular(value == 'full_time' ? 8 : 0),
            bottomLeft: Radius.circular(value == 'one_time' ? 8 : 0),
            bottomRight: Radius.circular(value == 'full_time' ? 8 : 0),
          ),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4B39EF), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null
              ? DateFormat("MMM d, yyyy").format(value)
              : "Select date",
          style: TextStyle(color: value != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildOneTimeField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isStart = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   label,
                //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                // ),
                const SizedBox(height: 4),
                Text(
                  value != null
                      ? DateFormat("MMM d, yyyy 'at' HH:mm").format(value)
                      : "Select $label date & time",
                  style: TextStyle(
                    color: value != null ? Colors.black : Colors.grey[500],
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          height: 400,
          child: SfCalendar(
            view: CalendarView.month,
            blackoutDates: controller.providerBusyTimes
                .where(
                  (slot) =>
                      slot.start.hour == 0 &&
                      slot.end.difference(slot.start).inHours >= 24,
                )
                .map(
                  (slot) => DateTime(
                    slot.start.year,
                    slot.start.month,
                    slot.start.day,
                  ),
                )
                .toList(),
            monthViewSettings: const MonthViewSettings(
              showTrailingAndLeadingDates: true,
            ),
            monthCellBuilder: (context, details) {
              final day = details.date;

              final isFullyBlocked = controller.providerBusyTimes.any(
                (slot) =>
                    slot.start.year == day.year &&
                    slot.start.month == day.month &&
                    slot.start.day == day.day &&
                    slot.start.hour == 0 &&
                    slot.end.difference(slot.start).inHours >= 24,
              );

              final isPartiallyBlocked =
                  !isFullyBlocked &&
                  controller.providerBusyTimes.any(
                    (slot) =>
                        slot.start.year == day.year &&
                        slot.start.month == day.month &&
                        slot.start.day == day.day,
                  );

              if (isFullyBlocked) {
                return controller._buildDayCell(
                  day,
                  Colors.red.withValues(alpha: 0.4),
                  Colors.white,
                );
              } else if (isPartiallyBlocked) {
                return controller._buildDayCell(
                  day,
                  Colors.orange.withValues(alpha: 0.3),
                  Colors.black,
                );
              }
              return controller._buildDayCell(day, null, Colors.black);
            },
            onTap: (details) {
              if (details.date != null &&
                  isDaySelectable(
                    details.date!,
                    controller.providerBusyTimes,
                  )) {
                Navigator.pop(context, details.date);
              }
            },
            specialRegions: controller.providerBusyTimes
                .map(
                  (r) => TimeRegion(
                    startTime: r.start,
                    endTime: r.end,
                    enablePointerInteraction: false,
                    color: Colors.red.withValues(alpha: 0.2),
                    text: 'Busy',
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    if (picked != null) {
      if (isStartDate) {
        controller.startDate.value = picked;

        // Ensure end date is at least +1 day after start
        if (controller.endDate.value == null ||
            controller.endDate.value!.isBefore(
              picked.add(const Duration(days: 1)),
            )) {
          controller.endDate.value = picked.add(const Duration(days: 1));
        }
      } else {
        controller.endDate.value = picked;
      }
      controller.update();
    }
  }

  Widget _buildOneTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).cardColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Select the start and end time for your one-time booking",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Start time selection
                _buildOneTimeField(
                  context,
                  label: "start",
                  value: controller.oneTimeStart.value,
                  onTap: () => controller.selectOneTimeStart(context),
                  isStart: true,
                ),

                // Visual connector
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.grey[400],
                      ),
                      Container(width: 2, height: 20, color: Colors.grey[300]),
                      Text("to", style: TextStyle(color: Colors.grey[600])),
                      Container(width: 2, height: 20, color: Colors.grey[300]),
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.grey[400],
                      ),
                    ],
                  ),
                ),

                // End time selection
                _buildOneTimeField(
                  context,
                  label: "end",
                  value: controller.oneTimeEnd.value,
                  onTap: () => controller.selectOneTimeEnd(context),
                  isStart: false,
                ),

                const SizedBox(height: 16),

                // Duration display
                Obx(() {
                  final start = controller.oneTimeStart.value;
                  final end = controller.oneTimeEnd.value;

                  if (start != null && end != null) {
                    final durationText = formatDuration(start, end);

                    final conflicts = getOverlapConflicts(
                      start,
                      end,
                      controller.providerBusyTimes, // your List<DateTimeRange>
                    );

                    final hasConflict = conflicts.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: hasConflict ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Duration: $durationText",
                              style: TextStyle(
                                color: hasConflict ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (hasConflict) ...[
                          const SizedBox(height: 6),
                          Text(
                            '⚠️ Provider is busy during the selected period on:',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          ...conflicts.map(
                            (c) => Text(
                              c,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String formatDuration(DateTime start, DateTime end) {
    if (end.isBefore(start)) return "Invalid";

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;
    int hours = end.hour - start.hour;
    int minutes = end.minute - start.minute;

    // Normalize negative values (borrow from higher units)
    if (minutes < 0) {
      minutes += 60;
      hours -= 1;
    }
    if (hours < 0) {
      hours += 24;
      days -= 1;
    }
    if (days < 0) {
      final prevMonth = DateTime(end.year, end.month, 0);
      days += prevMonth.day;
      months -= 1;
    }
    if (months < 0) {
      months += 12;
      years -= 1;
    }

    final parts = <String>[];
    if (years > 0) parts.add("${years}y");
    if (months > 0) parts.add("${months}mo");
    if (days > 0) parts.add("${days}d");
    if (hours > 0) parts.add("${hours}h");
    if (minutes > 0) parts.add("${minutes}m");

    return parts.isEmpty ? "0m" : parts.join(" ");
  }

  /// Returns a list of human-readable conflict descriptions
  List<String> getOverlapConflicts(
    DateTime start,
    DateTime end,
    List<DateTimeRange> busyTimes,
  ) {
    final conflicts = <String>[];
    final formatter = DateFormat("MMM d, HH:mm");
    final formatterSameDay = DateFormat("HH:mm");

    for (final busy in busyTimes) {
      if (start.isBefore(busy.end) && end.isAfter(busy.start)) {
        final busyStart = formatter.format(busy.start);
        final busyEnd =
            busy.start.day == busy.end.day &&
                busy.start.month == busy.end.month &&
                busy.start.year == busy.end.year
            ? formatterSameDay.format(busy.end)
            : formatter.format(busy.end);
        conflicts.add("$busyStart – $busyEnd");
      }
    }
    return conflicts;
  }

  Widget _buildRecurringFullTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildSectionHeader(
        //   "${controller.bookingType.value == 'recurring' ? 'Recurring' : 'Full-Time'} Schedule Details",
        // ),
        // Card(
        //   child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Frequency",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: controller.frequency.value,
              onChanged: (v) {
                if (v != null) controller.frequency.value = v;
              },
              items: const [
                DropdownMenuItem(value: "daily", child: Text("Daily")),
                DropdownMenuItem(value: "weekly", child: Text("Weekly")),
                DropdownMenuItem(value: "monthly", child: Text("Monthly")),
              ],
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Repeat every",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    value: controller.interval.value,
                    onChanged: (v) {
                      if (v != null) controller.interval.value = v;
                    },
                    items: List.generate(10, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text("${index + 1}"),
                      );
                    }),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF4B39EF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _getIntervalText(
                        controller.frequency.value,
                        controller.interval.value,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWindowsSelector(context),
          ],
        ),
        // ),
      ],
    );
  }

  String _getIntervalText(String frequency, int interval) {
    switch (frequency) {
      case 'daily':
        return interval == 1 ? 'day' : 'days';
      case 'weekly':
        return interval == 1 ? 'week' : 'weeks';
      case 'monthly':
        return interval == 1 ? 'month' : 'months';
      default:
        return '';
    }
  }

  Widget _buildWindowsSelector(BuildContext context) {
    // Don't show windows selector for one-time bookings
    if (controller.bookingType.value == 'one_time') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Obx(() {
          // For full-time, show a message that all days are included
          if (controller.bookingType.value == 'full_time') {
            return const Text(
              "Full-time includes all days of the week with default working hours",
              style: TextStyle(color: Colors.grey, fontSize: 10),
            );
          }

          return const Text(
            "Selected days and their time slots",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.windows.isEmpty &&
              controller.bookingType.value != 'full_time') {
            return NoWindowsSelected(controller: controller);
          }
          final weekdays = const [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];
          return Column(
            children: [
              ...controller.windows.entries.map((entry) {
                final weekday = entry.key;
                final dayName = weekdays[int.parse(weekday) - 1];
                final windows = entry.value;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  controller.windows.remove(weekday);
                                  controller.update();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(windows.length, (index) {
                            final window = windows[index];

                            final startTime = TimeOfDay(
                              hour: int.parse(window["start"]!.split(":")[0]),
                              minute: int.parse(window["start"]!.split(":")[1]),
                            );
                            final endTime = TimeOfDay(
                              hour: int.parse(window["end"]!.split(":")[0]),
                              minute: int.parse(window["end"]!.split(":")[1]),
                            );

                            final startBusy = BusyTimeHelper.isHourBusy(
                              int.parse(weekday),
                              startTime,
                              controller.disabledWeeklyBusy,
                            );
                            final endBusy = BusyTimeHelper.isHourBusy(
                              int.parse(weekday),
                              endTime,
                              controller.disabledWeeklyBusy,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  // Start time
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        // Get busy ranges for this weekday
                                        final busyRanges =
                                            _getBusyRangesForWeekday(
                                              int.parse(weekday),
                                              controller.providerBusyTimes,
                                            );

                                        // Create base date for the next occurrence of this weekday
                                        final baseDate = _getNextWeekday(
                                          int.parse(weekday),
                                        );

                                        final selectedTime =
                                            await showDialog<DateTime>(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: SizedBox(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.8,
                                                  child: FlexibleTimeSelector(
                                                    busyRanges: busyRanges,
                                                    onValidSelected:
                                                        (DateTime selected) {
                                                          Navigator.pop(
                                                            context,
                                                            selected,
                                                          );
                                                        },
                                                    baseDate: baseDate,
                                                    initiallyUse24Hour: true,
                                                  ),
                                                ),
                                              ),
                                            );

                                        if (selectedTime != null) {
                                          final newStart =
                                              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                                          final err = controller.validateWindow(
                                            weekday: int.parse(weekday),
                                            start: newStart,
                                            end: window["end"]!,
                                            indexToIgnore: index,
                                          );
                                          if (err != null) {
                                            Get.snackbar(
                                              "Invalid",
                                              err,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }
                                          window["start"] = newStart;
                                          controller.windows[weekday] = [
                                            ...windows,
                                          ];
                                          controller.update();
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: "Start Time",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFF4B39EF),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          errorText: startBusy ? "Busy" : null,
                                          enabled: !startBusy,
                                        ),
                                        child: Text(window["start"]!),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text('to'),
                                  ),
                                  // End time
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        // Get busy ranges for this weekday
                                        final busyRanges =
                                            _getBusyRangesForWeekday(
                                              int.parse(weekday),
                                              controller.providerBusyTimes,
                                            );

                                        // Create base date for the next occurrence of this weekday
                                        final baseDate = _getNextWeekday(
                                          int.parse(weekday),
                                        );

                                        final selectedTime =
                                            await showDialog<DateTime>(
                                              context: context,
                                              builder: (context) => Dialog(
                                                child: SizedBox(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.8,
                                                  child: FlexibleTimeSelector(
                                                    busyRanges: busyRanges,
                                                    onValidSelected:
                                                        (DateTime selected) {
                                                          Navigator.pop(
                                                            context,
                                                            selected,
                                                          );
                                                        },
                                                    baseDate: baseDate,
                                                    initiallyUse24Hour: true,
                                                  ),
                                                ),
                                              ),
                                            );

                                        if (selectedTime != null) {
                                          final newEnd =
                                              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                                          final err = controller.validateWindow(
                                            weekday: int.parse(weekday),
                                            start: window["start"]!,
                                            end: newEnd,
                                            indexToIgnore: index,
                                          );
                                          if (err != null) {
                                            Get.snackbar(
                                              "Invalid",
                                              err,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }
                                          window["end"] = newEnd;
                                          controller.windows[weekday] = [
                                            ...windows,
                                          ];
                                          controller.update();
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: "End Time",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFF4B39EF),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          errorText: endBusy ? "Busy" : null,
                                          enabled: !endBusy,
                                        ),
                                        child: Text(window["end"]!),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      windows.removeAt(index);
                                      if (windows.isEmpty) {
                                        controller.windows.remove(weekday);
                                      } else {
                                        controller.windows[weekday] = [
                                          ...windows,
                                        ];
                                      }
                                      controller.update();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              Logger().d(controller.windows);
                              Logger().d(controller.providerBusyTimes);
                              // Get busy ranges for this weekday
                              final busyRanges = _getBusyRangesForWeekday(
                                int.parse(weekday),
                                controller.providerBusyTimes,
                              );
                              Logger().d(busyRanges);

                              // Create base date for the next occurrence of this weekday
                              final baseDate = _getNextWeekday(
                                int.parse(weekday),
                              );

                              final selectedStartTime =
                                  await showDialog<DateTime>(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.8,
                                        child: FlexibleTimeSelector(
                                          busyRanges: busyRanges,
                                          onValidSelected: (DateTime selected) {
                                            Navigator.pop(context, selected);
                                          },
                                          baseDate: baseDate,
                                          initiallyUse24Hour: true,
                                        ),
                                      ),
                                    ),
                                  );
                              final selectedEndTime =
                                  await showDialog<DateTime>(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.8,
                                        child: FlexibleTimeSelector(
                                          busyRanges: busyRanges,
                                          onValidSelected: (DateTime selected) {
                                            Navigator.pop(context, selected);
                                          },
                                          baseDate: baseDate,
                                          initiallyUse24Hour: true,
                                        ),
                                      ),
                                    ),
                                  );

                              if (selectedStartTime != null &&
                                  selectedEndTime != null) {
                                final startStr =
                                    "${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}";

                                final endDt = DateTime(
                                  0,
                                  1,
                                  1,
                                  selectedEndTime.hour,
                                  selectedEndTime.minute,
                                );
                                final endStr =
                                    "${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}";

                                final err = controller.validateWindow(
                                  weekday: int.parse(weekday),
                                  start: startStr,
                                  end: endStr,
                                );
                                if (err != null) {
                                  Get.snackbar(
                                    "Invalid",
                                    err,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                windows.add({"start": startStr, "end": endStr});
                                controller.windows[weekday] = [...windows];
                                controller.update();
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Add time window"),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
              }),
              // Only show "Add day" for recurring, not full-time
              if (controller.bookingType.value == 'recurring' ||
                  (controller.bookingType.value == 'full_time' &&
                      controller.windows.length < 7))
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      // Show a dialog to select a weekday
                      final weekdays = const [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday',
                      ];

                      final selectedWeekday = await showDialog<int>(
                        context: Get.context!,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Select a day of the week"),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 7,
                                itemBuilder: (BuildContext context, int index) {
                                  final weekday =
                                      index + 1; // 1 = Monday, ... 7 = Sunday
                                  final dayName = weekdays[index];
                                  return ListTile(
                                    title: Text(dayName),
                                    onTap: () {
                                      Logger().d(weekday);
                                      Navigator.pop(context, weekday);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );

                      if (selectedWeekday != null) {
                        if (controller.windows.containsKey(
                          selectedWeekday.toString(),
                        )) {
                          Get.snackbar(
                            "Day already selected",
                            "This day has already been selected",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        // Add the selected weekday with default time
                        Logger().d(controller.windows);
                        Logger().d(controller.providerBusyTimes);
                        // Get busy ranges for this weekday
                        final busyRanges = _getBusyRangesForWeekday(
                          selectedWeekday,
                          controller.providerBusyTimes,
                        );
                        Logger().d(busyRanges);

                        // Create base date for the next occurrence of this weekday
                        final baseDate = _getNextWeekday(selectedWeekday);

                        final selectedStartTime = await showDialog<DateTime>(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: FlexibleTimeSelector(
                                title: 'Select Start Time',
                                busyRanges: busyRanges,
                                onValidSelected: (DateTime selected) {
                                  Navigator.pop(context, selected);
                                },
                                baseDate: baseDate,
                                initiallyUse24Hour: true,
                              ),
                            ),
                          ),
                        );
                        final selectedEndTime = await showDialog<DateTime>(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: FlexibleTimeSelector(
                                title: 'Select End Time',
                                busyRanges: busyRanges,
                                onValidSelected: (DateTime selected) {
                                  Navigator.pop(context, selected);
                                },
                                baseDate: baseDate,
                                initiallyUse24Hour: true,
                              ),
                            ),
                          ),
                        );

                        if (selectedStartTime != null &&
                            selectedEndTime != null) {
                          final startStr =
                              "${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}";

                          final endDt = DateTime(
                            0,
                            1,
                            1,
                            selectedEndTime.hour,
                            selectedEndTime.minute,
                          );
                          final endStr =
                              "${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}";

                          final err = controller.validateWindow(
                            weekday: selectedWeekday,
                            start: startStr,
                            end: endStr,
                          );
                          if (err != null) {
                            Get.snackbar(
                              "Invalid",
                              err,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          controller.windows[selectedWeekday.toString()] = [
                            {"start": startStr, "end": endStr},
                          ];
                          controller.update();
                        }
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add day"),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // Helper function to get busy ranges for a specific weekday
  List<DateTimeRange> _getBusyRangesForWeekday(
    int weekday,
    List<DateTimeRange> providerBusyTimes,
  ) {
    final ScheduleValidationHelper helper = ScheduleValidationHelper();
    final intervals = helper.busyIntervalsForWeekday(
      weekday,
      providerBusyTimes,
    );

    // Create a base date for the next occurrence of this weekday
    final baseDate = _getNextWeekday(weekday);

    return intervals.map((interval) {
      final startMinutes = interval['start']!;
      final endMinutes = interval['end']!;

      final startHour = startMinutes ~/ 60;
      final startMinute = startMinutes % 60;
      final endHour = endMinutes ~/ 60;
      final endMinute = endMinutes % 60;

      DateTime start = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        startHour,
        startMinute,
      );
      DateTime end = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        endHour,
        endMinute,
      );

      // Handle wrap-around (end time is next day)
      if (endMinutes == 1440) {
        end = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          59,
          59,
          999,
        );
      }

      return DateTimeRange(start: start, end: end);
    }).toList();
  }

  // Helper function to get the next occurrence of a weekday
  DateTime _getNextWeekday(int weekday) {
    DateTime today = DateTime.now();
    int daysToAdd = (weekday - today.weekday) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // If today is the weekday, get next week
    return today.add(Duration(days: daysToAdd));
  }
}

class NoWindowsSelected extends StatelessWidget {
  const NoWindowsSelected({super.key, required this.controller});

  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "No days selected yet",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              // Show a dialog to select a weekday
              final weekdays = const [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];

              final selectedWeekday = await showDialog<int>(
                context: Get.context!,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Select a day of the week"),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 7,
                        itemBuilder: (BuildContext context, int index) {
                          final weekday =
                              index + 1; // 1 = Monday, ... 7 = Sunday
                          final dayName = weekdays[index];
                          return ListTile(
                            title: Text(dayName),
                            onTap: () {
                              Logger().d(weekday);
                              Navigator.pop(context, weekday);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );

              if (selectedWeekday != null) {
                if (controller.windows.containsKey(
                  selectedWeekday.toString(),
                )) {
                  Get.snackbar(
                    "Day already selected",
                    "This day has already been selected",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                // Add the selected weekday with default time
                Logger().d(controller.windows);
                Logger().d(controller.providerBusyTimes);
                // Get busy ranges for this weekday
                final busyRanges = _getBusyRangesForWeekday(
                  selectedWeekday,
                  controller.providerBusyTimes,
                );
                Logger().d(busyRanges);

                // Create base date for the next occurrence of this weekday
                final baseDate = _getNextWeekday(selectedWeekday);

                final selectedStartTime = await showDialog<DateTime>(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: FlexibleTimeSelector(
                        title: 'Select Start Time',
                        busyRanges: busyRanges,
                        onValidSelected: (DateTime selected) {
                          Navigator.pop(context, selected);
                        },
                        baseDate: baseDate,
                        initiallyUse24Hour: true,
                      ),
                    ),
                  ),
                );
                final selectedEndTime = await showDialog<DateTime>(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: FlexibleTimeSelector(
                        title: 'Select End Time',
                        busyRanges: busyRanges,
                        onValidSelected: (DateTime selected) {
                          Navigator.pop(context, selected);
                        },
                        baseDate: baseDate,
                        initiallyUse24Hour: true,
                      ),
                    ),
                  ),
                );

                if (selectedStartTime != null && selectedEndTime != null) {
                  final startStr =
                      "${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}";

                  final endDt = DateTime(
                    0,
                    1,
                    1,
                    selectedEndTime.hour,
                    selectedEndTime.minute,
                  );
                  final endStr =
                      "${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}";

                  final err = controller.validateWindow(
                    weekday: selectedWeekday,
                    start: startStr,
                    end: endStr,
                  );
                  if (err != null) {
                    Get.snackbar(
                      "Invalid",
                      err,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  controller.windows[selectedWeekday.toString()] = [
                    {"start": startStr, "end": endStr},
                  ];
                  controller.update();
                }
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Add day"),
          ),
        ),
      ],
    );
  }

  List<DateTimeRange> _getBusyRangesForWeekday(
    int weekday,
    List<DateTimeRange> providerBusyTimes,
  ) {
    final ScheduleValidationHelper helper = ScheduleValidationHelper();
    final intervals = helper.busyIntervalsForWeekday(
      weekday,
      providerBusyTimes,
    );

    // Create a base date for the next occurrence of this weekday
    final baseDate = _getNextWeekday(weekday);

    return intervals.map((interval) {
      final startMinutes = interval['start']!;
      final endMinutes = interval['end']!;

      final startHour = startMinutes ~/ 60;
      final startMinute = startMinutes % 60;
      final endHour = endMinutes ~/ 60;
      final endMinute = endMinutes % 60;

      DateTime start = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        startHour,
        startMinute,
      );
      DateTime end = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        endHour,
        endMinute,
      );

      // Handle wrap-around (end time is next day)
      if (endMinutes == 1440) {
        end = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          59,
          59,
          999,
        );
      }

      return DateTimeRange(start: start, end: end);
    }).toList();
  }

  // Helper function to get the next occurrence of a weekday
  DateTime _getNextWeekday(int weekday) {
    DateTime today = DateTime.now();
    int daysToAdd = (weekday - today.weekday) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // If today is the weekday, get next week
    return today.add(Duration(days: daysToAdd));
  }
}
