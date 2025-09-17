// flexible_time_selector.dart
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

/// FlexibleTimeSelector
/// - toggle between 24h circular wheel and 12h cupertino picker
/// - circular wheel contains hour labels + half-hour ticks + busy arcs
/// - knob maps correctly (TOP = 00:00)
/// - enter HH:mm via text input to position the knob
class FlexibleTimeSelector extends StatefulWidget {
  final List<DateTimeRange>
  busyRanges; // should already be filtered to the target day
  final ValueChanged<DateTime> onValidSelected;
  final DateTime baseDate;
  final bool initiallyUse24Hour;
  final String? title;

  const FlexibleTimeSelector({
    super.key,
    required this.busyRanges,
    required this.onValidSelected,
    required this.baseDate,
    this.initiallyUse24Hour = true,
    this.title,
  });

  @override
  State<FlexibleTimeSelector> createState() => _FlexibleTimeSelectorState();
}

class _FlexibleTimeSelectorState extends State<FlexibleTimeSelector> {
  late bool use24;
  DateTime? selected;

  @override
  void initState() {
    super.initState();
    use24 = widget.initiallyUse24Hour;
    selected = DateTime(
      widget.baseDate.year,
      widget.baseDate.month,
      widget.baseDate.day,
      0,
      0,
    );
  }

  bool _isBusy(DateTime dt) {
    for (final r in widget.busyRanges) {
      if (!dt.isBefore(r.start) && dt.isBefore(r.end)) return true;
    }
    return false;
  }

  void _onSelected(DateTime dt) {
    // Called when the child widget reports a valid selection (on release / confirm).
    if (_isBusy(dt)) {
      Get.snackbar(
        "Busy Time",
        "⚠️ That time overlaps with a busy slot",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    setState(() => selected = dt);
    widget.onValidSelected(dt);
  }

  @override
  Widget build(BuildContext context) {
    Logger().d(widget.busyRanges);
    return Column(
      children: [
        // toggle and date
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    widget.title!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Display:"),
                  const SizedBox(width: 8),
                  ToggleButtons(
                    isSelected: [use24, !use24],
                    onPressed: (i) {
                      setState(() => use24 = i == 0);
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('24h'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('12h'),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),

        // selector body
        Expanded(
          child: use24
              ? CircularTimeWheel(
                  busyRanges: widget.busyRanges,
                  baseDate: widget.baseDate,
                  initialSelected: selected!,
                  onValidSelected: _onSelected,
                )
              : Cupertino12hPicker(
                  busyRanges: widget.busyRanges,
                  baseDate: widget.baseDate,
                  onValidSelected: _onSelected,
                ),
        ),
        SizedBox(
          height: 50,
          width: 360,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, selected);
            },
            child: const Text('Select', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

/// ------------------- 24h Circular Wheel -------------------
class CircularTimeWheel extends StatefulWidget {
  final List<DateTimeRange> busyRanges; // assumed filtered to the day
  final ValueChanged<DateTime> onValidSelected;
  final DateTime baseDate;
  final DateTime initialSelected;

  const CircularTimeWheel({
    super.key,
    required this.busyRanges,
    required this.onValidSelected,
    required this.baseDate,
    required this.initialSelected,
  });

  @override
  State<CircularTimeWheel> createState() => _CircularTimeWheelState();
}

class _CircularTimeWheelState extends State<CircularTimeWheel> {
  // angle in radians; default top (-pi/2) = midnight.
  double angle = -pi / 2;
  DateTime? liveCandidate;

  static const double reference = -pi / 2; // top = midnight

  @override
  void initState() {
    super.initState();
    // initialize angle from initialSelected
    final minutes =
        widget.initialSelected.hour * 60 + widget.initialSelected.minute;
    final frac = minutes / 1440.0;
    angle = reference + 2 * pi * frac;
    liveCandidate = widget.initialSelected;
  }

  /// Convert an angle (atan2 result) to a DateTime on baseDate.
  DateTime _angleToTime(double ang) {
    double norm = (ang - reference) % (2 * pi);
    if (norm < 0) norm += 2 * pi;
    final fraction = norm / (2 * pi); // 0 => midnight, 0.5 => noon
    final totalMinutes = (fraction * 1440).round() % 1440;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return DateTime(
      widget.baseDate.year,
      widget.baseDate.month,
      widget.baseDate.day,
      h,
      m,
    );
  }

  /// Convert an explicit time (h,m) into angle
  double _timeToAngle(int hour, int minute) {
    final minutes = (hour * 60 + minute) % 1440;
    final frac = minutes / 1440.0;
    return reference + 2 * pi * frac;
  }

  bool _isBusy(DateTime candidate) {
    for (final r in widget.busyRanges) {
      if (!candidate.isBefore(r.start) && candidate.isBefore(r.end))
        return true;
    }
    return false;
  }

  void _updateAngleFromLocal(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final vec = localPos - center;
    setState(() {
      angle = atan2(vec.dy, vec.dx);
      liveCandidate = _angleToTime(angle);
    });
  }

  void _onDragEnd() {
    if (liveCandidate == null) return;
    if (_isBusy(liveCandidate!)) {
      // show snackbar (Get) only on release into busy area
      Get.snackbar(
        "Busy Time",
        "⚠️ That time overlaps with a busy slot",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    widget.onValidSelected(liveCandidate!);
  }

  Future<void> _showManualInput() async {
    final controller = TextEditingController(
      text: intl.DateFormat('HH:mm').format(liveCandidate ?? DateTime.now()),
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter time (HH:mm)'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
              ],
              decoration: const InputDecoration(hintText: 'HH:mm'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter time';
                final r = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$');
                if (!r.hasMatch(v.trim())) return 'Invalid format';
                return null;
              },
              onSaved: (v) {
                // auto-pad
                final parts = v!.split(':');
                final h = parts[0].padLeft(2, '0');
                final m = parts[1].padLeft(2, '0');
                controller.text = "$h:$m";
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final text = controller.text.trim();
      final parts = text.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final candidate = DateTime(
        widget.baseDate.year,
        widget.baseDate.month,
        widget.baseDate.day,
        h,
        m,
      );

      if (_isBusy(candidate)) {
        Get.snackbar(
          "Busy Time",
          "⚠️ That time overlaps with a busy slot",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      setState(() {
        angle = _timeToAngle(h, m);
        liveCandidate = candidate;
      });
      widget.onValidSelected(candidate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final display =
        liveCandidate ??
        DateTime(
          widget.baseDate.year,
          widget.baseDate.month,
          widget.baseDate.day,
          0,
          0,
        );

    return Column(
      children: [
        // Busy intervals summary
        if (widget.busyRanges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.busyRanges.map((b) {
                final start =
                    // b.start.isBefore(widget.baseDate)
                    //     ? DateTime(
                    //         widget.baseDate.year,
                    //         widget.baseDate.month,
                    //         widget.baseDate.day,
                    //         0,
                    //         0,
                    //       )
                    //     :
                    b.start;
                final end = b.end;
                return Chip(
                  backgroundColor: Colors.red.withOpacity(0.12),
                  label: Text(
                    '${intl.DateFormat.Hm().format(start)}–${intl.DateFormat.Hm().format(end)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }).toList(),
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return GestureDetector(
                onPanStart: (d) =>
                    _updateAngleFromLocal(d.localPosition, constraints.biggest),
                onPanUpdate: (d) =>
                    _updateAngleFromLocal(d.localPosition, constraints.biggest),
                onPanEnd: (d) => _onDragEnd(),
                child: CustomPaint(
                  size: constraints.biggest,
                  painter: _ClockPainter(
                    busyRanges: widget.busyRanges,
                    angle: angle,
                    // choose a larger wheel/thickness inside painter
                  ),
                ),
              );
            },
          ),
        ),

        // bottom: display + edit icon
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              intl.DateFormat('HH:mm').format(display),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _showManualInput,
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Enter time manually (HH:mm)',
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  final List<DateTimeRange> busyRanges;
  final double angle;

  _ClockPainter({required this.busyRanges, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final TextDirection textDir =
        TextDirection.ltr; // safe assignment for various SDKs
    final center = Offset(size.width / 2, size.height / 2);

    // make the wheel wider by using a slightly smaller inset
    final radius = min(size.width, size.height) / 2 - 20;

    // outer ring
    final basePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, basePaint);

    // Busy arcs (same reference: -pi/2 = 00:00)
    for (final r in busyRanges) {
      final startMinutes = (r.start.hour * 60 + r.start.minute).toDouble();
      final endMinutes = (r.end.hour * 60 + r.end.minute).toDouble();

      final startFrac = startMinutes / 1440.0;
      final endFrac = endMinutes / 1440.0;
      final startAng = -pi / 2 + 2 * pi * startFrac;
      final endAng = -pi / 2 + 2 * pi * endFrac;

      double sweep;
      if (endAng >= startAng) {
        sweep = endAng - startAng;
      } else {
        // wrap-around
        sweep = 2 * pi - (startAng - endAng);
      }

      final paint = Paint()
        ..color = Colors.red.withOpacity(0.30)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 12),
        startAng,
        sweep,
        false,
        paint,
      );
    }

    // ticks: hour (long) + half-hour (short)
    for (int hour = 0; hour < 24; hour++) {
      for (int half = 0; half < 2; half++) {
        final minutes = hour * 60 + half * 30;
        final frac = minutes / 1440.0;
        final ang = -pi / 2 + 2 * pi * frac;

        final tickLen = half == 0 ? 14.0 : 7.0;
        final paint = Paint()
          ..color = half == 0 ? Colors.black : Colors.grey
          ..strokeWidth = half == 0 ? 2.5 : 1.5;

        final inner = Offset(
          center.dx + cos(ang) * (radius - tickLen - 6),
          center.dy + sin(ang) * (radius - tickLen - 6),
        );
        final outer = Offset(
          center.dx + cos(ang) * radius,
          center.dy + sin(ang) * radius,
        );
        canvas.drawLine(inner, outer, paint);
      }
    }

    // hour labels (24 numbers), placed slightly inside the hour ticks
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: textDir,
    );
    for (int i = 0; i < 24; i++) {
      final frac = i / 24.0;
      final ang = -pi / 2 + 2 * pi * frac;
      final dx = center.dx + cos(ang) * (radius - 36);
      final dy = center.dy + sin(ang) * (radius - 36);
      final label = i.toString().padLeft(2, '0');
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 11, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(dx - textPainter.width / 2, dy - textPainter.height / 2),
      );
    }

    // knob: change color if knob currently sits inside a busy arc
    final knobX = center.dx + cos(angle) * (radius - 6);
    final knobY = center.dy + sin(angle) * (radius - 6);

    // compute current knob time to color it
    final norm = (angle - (-pi / 2)) % (2 * pi);
    final fraction = (norm < 0 ? norm + 2 * pi : norm) / (2 * pi);
    final totalMinutes = (fraction * 1440).round() % 1440;
    final knobH = totalMinutes ~/ 60;
    final knobM = totalMinutes % 60;
    bool knobBusy = false;
    for (final r in busyRanges) {
      final candidate = DateTime(0, 1, 1, knobH, knobM);
      final rStart = DateTime(0, 1, 1, r.start.hour, r.start.minute);
      final rEnd = DateTime(0, 1, 1, r.end.hour, r.end.minute);
      // crude check (all busyRanges should be same-day filtered before sending)
      if (!candidate.isBefore(rStart) && candidate.isBefore(rEnd)) {
        knobBusy = true;
        break;
      }
    }

    canvas.drawCircle(
      Offset(knobX, knobY),
      12,
      Paint()..color = knobBusy ? Colors.redAccent : Colors.blueAccent,
    );

    // center dot
    canvas.drawCircle(center, 6, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ------------------- 12h Cupertino Picker -------------------
class Cupertino12hPicker extends StatefulWidget {
  final List<DateTimeRange> busyRanges; // filtered to the day
  final ValueChanged<DateTime> onValidSelected;
  final DateTime baseDate;

  const Cupertino12hPicker({
    super.key,
    required this.busyRanges,
    required this.onValidSelected,
    required this.baseDate,
  });

  @override
  State<Cupertino12hPicker> createState() => _Cupertino12hPickerState();
}

class _Cupertino12hPickerState extends State<Cupertino12hPicker> {
  int hour = 12;
  int minute = 0;
  String period = "AM";

  bool _isBusy(DateTime dt) {
    for (final r in widget.busyRanges) {
      if (!dt.isBefore(r.start) && dt.isBefore(r.end)) return true;
    }
    return false;
  }

  DateTime _currentSelection() {
    int h = hour % 12 + (period == "PM" ? 12 : 0);
    return DateTime(
      widget.baseDate.year,
      widget.baseDate.month,
      widget.baseDate.day,
      h,
      minute,
    );
  }

  void _commitSelection() {
    final dt = _currentSelection();
    if (_isBusy(dt)) {
      Get.snackbar(
        "Busy Time",
        "⚠️ That hour overlaps with a busy slot",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      widget.onValidSelected(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Hour picker
          Expanded(
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (n) {
                _commitSelection();
                return false;
              },
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: 11),
                itemExtent: 32,
                onSelectedItemChanged: (i) {
                  hour = i + 1;
                },
                children: List.generate(12, (i) {
                  final display = (i + 1).toString();
                  final h24 = (i + 1) % 12 + (period == "PM" ? 12 : 0);
                  final dt = DateTime(
                    widget.baseDate.year,
                    widget.baseDate.month,
                    widget.baseDate.day,
                    h24,
                    minute,
                  );
                  final busy = _isBusy(dt);
                  return Center(
                    child: Text(
                      display,
                      style: TextStyle(color: busy ? Colors.red : Colors.black),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Minute picker
          Expanded(
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (n) {
                _commitSelection();
                return false;
              },
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: 0),
                itemExtent: 32,
                onSelectedItemChanged: (i) {
                  minute = i * 5;
                },
                children: List.generate(12, (i) {
                  final display = (i * 5).toString().padLeft(2, "0");
                  final h24 = hour % 12 + (period == "PM" ? 12 : 0);
                  final dt = DateTime(
                    widget.baseDate.year,
                    widget.baseDate.month,
                    widget.baseDate.day,
                    h24,
                    i * 5,
                  );
                  final busy = _isBusy(dt);
                  return Center(
                    child: Text(
                      display,
                      style: TextStyle(color: busy ? Colors.red : Colors.black),
                    ),
                  );
                }),
              ),
            ),
          ),

          // AM/PM picker
          Expanded(
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (n) {
                _commitSelection();
                return false;
              },
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: 0),
                itemExtent: 32,
                onSelectedItemChanged: (i) {
                  period = i == 0 ? "AM" : "PM";
                },
                children: const [
                  Center(child: Text("AM")),
                  Center(child: Text("PM")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
