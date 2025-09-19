import 'package:enderase/controllers/booking_detail_controller.dart';
import 'package:enderase/models/booking.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final int bookingId = args is int ? args : (args['id'] as int);
    final controller = Get.put(BookingDetailController(bookingId: bookingId));

    return Scaffold(
      appBar: AppBar(
        title: Text('booking_id'.trParams({'id': bookingId.toString()})),
      ),
      body: Obx(() {
        if (controller.loading.value == ApiCallStatus.error) {
          return Center(
            child: ErrorCard(
              errorData: controller.error.value,
              refresh: controller.fetchBooking,
            ),
          );
        }
        if (controller.loading.value == ApiCallStatus.loading ||
            controller.booking.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final Booking b = controller.booking.value!;
        final String? avatar = b.provider?['profile_picture'];
        final name = b.providerDisplayName;
        final category = b.categoryDisplayName;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(avatar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(b),
                ],
              ),
              const SizedBox(height: 16),

              _sectionTitle('schedule'.tr),
              _scheduleWidget(b),
              const SizedBox(height: 16),

              if (b.meta != null && b.meta!.isNotEmpty) ...[
                _sectionTitle('details'.tr),
                _metaCard(b),
                const SizedBox(height: 16),
              ],

              _sectionTitle('created'.tr),
              Text(_formatDateTime(b.createdAt)),
              const SizedBox(height: 24),

              if (controller.canRateProvider) ...[
                _sectionTitle('rating'.tr),
                const SizedBox(height: 8),
                _ratingForm(controller),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatar(String? url) {
    const double size = 56;
    if (url != null && url.isNotEmpty) {
      return SizedBox(
        height: size,
        width: size,
        child: cachedNetworkImageWrapper(
          imageUrl: url,
          height: size,
          width: size,
          imageBuilder: (ctx, provider) =>
              CircleAvatar(radius: size / 2, backgroundImage: provider),
          placeholderBuilder: (ctx, _) => const CircleAvatar(
            radius: size / 2,
            child: Icon(Icons.person_outline),
          ),
          errorWidgetBuilder: (ctx, _, __) => const CircleAvatar(
            radius: size / 2,
            child: Icon(Icons.person_outline),
          ),
        ),
      );
    }
    return const CircleAvatar(radius: 28, child: Icon(Icons.person_outline));
  }

  Widget _statusPill(Booking b) {
    Color color;
    switch (b.statusColor) {
      case 'green':
        color = Colors.green;
        break;
      case 'orange':
        color = Colors.orange;
        break;
      case 'red':
        color = Colors.red;
        break;
      case 'blue':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        b.statusDisplay,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _scheduleWidget(Booking b) {
    final sch = b.schedule ?? {};
    final type = (sch['type'] ?? '').toString();
    if (type == 'one_time'.tr) {
      final start = b.formattedStartTime;
      final end = b.formattedEndTime;
      return Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text('$start → $end')),
        ],
      );
    }
    final freq = (sch['frequency'] ?? '').toString();
    final interval = sch['interval']?.toString();
    // Support both legacy map windows and new list windows format
    final dynamic rawWindows = sch['windows'];
    Map<String, dynamic> windowsByDay = const {};
    if (rawWindows is Map) {
      windowsByDay = Map<String, dynamic>.from(rawWindows);
    } else if (rawWindows is List) {
      // Convert list of {day_of_week,start_time,end_time} to map day->[ranges]
      final Map<String, List<Map<String, String>>> tmp = {};
      for (final w in rawWindows) {
        if (w is Map) {
          final String dayKey = (w['day_of_week'] ?? w['day'] ?? '').toString();
          final String start = (w['start_time'] ?? w['start'] ?? '').toString();
          final String end = (w['end_time'] ?? w['end'] ?? '').toString();
          if (dayKey.isEmpty || start.isEmpty || end.isEmpty) continue;
          tmp.putIfAbsent(dayKey, () => []);
          tmp[dayKey]!.add({'start': start, 'end': end});
        }
      }
      windowsByDay = tmp.map((k, v) => MapEntry(k, v));
    }
    final title =
        '${type == 'recurring' ? 'recurring'.tr : 'full_time'.tr} • ${_freq(freq)}${interval != null ? ' • ${'every'.tr} $interval ${_suffix(freq, int.tryParse(interval) ?? 1)}' : ''}';
    final chips = <Widget>[];
    if (windowsByDay.isNotEmpty) {
      final keys = windowsByDay.keys.toList()
        ..sort(
          (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
        );
      for (final k in keys) {
        final day = _day(int.tryParse(k) ?? 0);
        final List rows = windowsByDay[k] is List
            ? (windowsByDay[k] as List)
            : const [];
        if (rows.isEmpty) continue;
        final ranges = rows
            .map((e) {
              final m = (e is Map) ? e : {};
              final s = (m['start'] ?? m['start_time'] ?? '').toString();
              final end = (m['end'] ?? m['end_time'] ?? '').toString();
              return '$s–$end';
            })
            .join(', ');
        chips.add(
          Chip(
            label: Text('$day: $ranges', style: const TextStyle(fontSize: 12)),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: chips),
        ],
      ],
    );
  }

  Widget _metaCard(Booking b) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: b.meta!.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${e.key.tr}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatMetaValue(e.value),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _ratingForm(BookingDetailController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            final idx = i + 1;
            final selected = c.ratingValue.value >= idx;
            return IconButton(
              onPressed: () => c.ratingValue.value = idx,
              icon: Icon(
                selected ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            );
          }),
        ),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: 'write_your_comment'.tr),
          onChanged: (v) => c.ratingComment.value = v,
        ),
        const SizedBox(height: 8),
        Obx(
          () => ElevatedButton(
            onPressed: c.submittingRating.value ? null : c.submitRating,
            child: c.submittingRating.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('submit'.tr, style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final parsed = DateTime.parse(dateTime).toLocal();
      return '${parsed.day}/${parsed.month}/${parsed.year} ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatMetaValue(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'yes'.tr : 'no'.tr;
    if (value is List) return value.map((e) => e.toString().tr).join(', ');
    return value.toString().tr;
  }

  String _freq(String f) {
    switch (f) {
      case 'daily':
        return 'daily'.tr;
      case 'weekly':
        return 'weekly'.tr;
      case 'monthly':
        return 'monthly'.tr;
      default:
        return f;
    }
  }

  String _suffix(String f, int n) {
    switch (f) {
      case 'daily':
        return n == 1 ? 'day'.tr : 'days'.tr;
      case 'weekly':
        return n == 1 ? 'week'.tr : 'weeks'.tr;
      case 'monthly':
        return n == 1 ? 'month'.tr : 'months'.tr;
      default:
        return 'times'.tr;
    }
  }

  String _day(int idx) {
    switch (idx) {
      case 1:
        return 'mon'.tr;
      case 2:
        return 'tue'.tr;
      case 3:
        return 'wed'.tr;
      case 4:
        return 'thu'.tr;
      case 5:
        return 'fri'.tr;
      case 6:
        return 'sat'.tr;
      case 7:
        return 'sun'.tr;
      default:
        return '${'day'.tr} $idx';
    }
  }
}
