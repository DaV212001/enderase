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
    final int bookingId = Get.arguments as int;
    final controller = Get.put(BookingDetailController(bookingId: bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
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

              _sectionTitle('Schedule'),
              _scheduleWidget(b),
              const SizedBox(height: 16),

              if (b.meta != null && b.meta!.isNotEmpty) ...[
                _sectionTitle('Details'),
                _metaCard(b),
                const SizedBox(height: 16),
              ],

              _sectionTitle('Created'),
              Text(_formatDateTime(b.createdAt)),
              const SizedBox(height: 24),

              if (controller.canRateProvider) ...[
                _sectionTitle('Rate Provider'),
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
    if (type == 'one_time') {
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
    final windows = (sch['windows'] is Map)
        ? Map<String, dynamic>.from(sch['windows'])
        : const {};
    final title =
        '${type == 'recurring' ? 'Recurring' : 'Full-Time'} • ${_freq(freq)}${interval != null ? ' • Every $interval ${_suffix(freq, int.tryParse(interval) ?? 1)}' : ''}';
    final chips = <Widget>[];
    if (windows.isNotEmpty) {
      final keys = windows.keys.toList()
        ..sort(
          (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
        );
      for (final k in keys) {
        final day = _day(int.tryParse(k) ?? 0);
        final List rows = windows[k] is List ? (windows[k] as List) : const [];
        if (rows.isEmpty) continue;
        final ranges = rows
            .map((e) {
              final m = (e is Map) ? e : {};
              return '${(m['start'] ?? '').toString()}–${(m['end'] ?? '').toString()}';
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
          decoration: const InputDecoration(hintText: 'Write your comment'),
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
                : const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final parsed = DateTime.parse(dateTime);
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
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return f;
    }
  }

  String _suffix(String f, int n) {
    switch (f) {
      case 'daily':
        return n == 1 ? 'day' : 'days';
      case 'weekly':
        return n == 1 ? 'week' : 'weeks';
      case 'monthly':
        return n == 1 ? 'month' : 'months';
      default:
        return 'times';
    }
  }

  String _day(int idx) {
    switch (idx) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Day $idx';
    }
  }
}
