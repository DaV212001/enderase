import 'package:enderase/setup_files/wrappers/cached_image_widget_wrapper.dart';
import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/booking.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.isShimmer,
  });

  final Booking booking;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ShimmerWrapper(
          isEnabled: isShimmer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Provider avatar + name/category + status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.providerDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.categoryDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          booking.statusColor,
                        ).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(booking.statusColor),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        booking.statusDisplay,
                        style: TextStyle(
                          color: _getStatusColor(booking.statusColor),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time information (supports dynamic schedule one-time fields)
                // Schedule section based on schedule rules
                _buildScheduleSection(booking),
                const SizedBox(height: 8),
                const SizedBox(height: 8),

                // Provider and Category info
                // (Removed duplicate provider/category chips)

                // Notes if available
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.note,
                    label: 'notes'.tr,
                    value: booking.notes!,
                  ),
                ],

                // Meta information if available
                if (booking.meta != null && booking.meta!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'booking_details'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...booking.meta!.entries.map((entry) {
                          return _buildMetaRow(
                            entry.key.tr,
                            _formatMetaValue(entry.value),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Avatar based on provider.profile_picture when available
  Widget _buildAvatar() {
    final String? url = booking.provider != null
        ? (booking.provider!['profile_picture'] as String?)
        : null;
    const double size = 44;
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
    return const CircleAvatar(radius: 22, child: Icon(Icons.person_outline));
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor.toLowerCase()) {
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

  String _buildScheduleSummary(Booking b) {
    final hasStart = b.startTime != null;
    final hasEnd = b.endTime != null;
    if (hasStart && hasEnd) {
      try {
        final s = DateTime.parse(b.startTime!);
        final e = DateTime.parse(b.endTime!);
        final sameDay =
            s.year == e.year && s.month == e.month && s.day == e.day;
        final sStr =
            '${s.day}/${s.month} ${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
        final eStrTime =
            '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}';
        final eStr = sameDay ? eStrTime : '${e.day}/${e.month} $eStrTime';
        return '$sStr → $eStr';
      } catch (_) {
        return '${b.formattedStartTime} → ${b.formattedEndTime}';
      }
    } else if (hasStart) {
      return b.formattedStartTime;
    } else if (hasEnd) {
      return b.formattedEndTime;
    }
    return '';
  }

  // Build schedule UI according to rules:
  // - type: one_time/recurring/full_time
  // - frequency, interval (nullable for one_time)
  // - windows: map weekday -> list of {start,end}
  Widget _buildScheduleSection(Booking b) {
    final sch = b.schedule ?? {};
    final String type = (sch['type'] ?? '').toString();
    if (type == 'one_time') {
      final summary = _buildScheduleSummary(b);
      if (summary.isEmpty) return const SizedBox.shrink();
      return Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }

    // recurring or full_time
    final String freq = (sch['frequency'] ?? '').toString();
    final int? interval = _tryParseInt(sch['interval']);
    final Map<String, dynamic> windows = (sch['windows'] is Map)
        ? Map<String, dynamic>.from(sch['windows'])
        : const {};

    final headerParts = <String>[];
    if (type == 'recurring') headerParts.add('Recurring');
    if (type == 'full_time') headerParts.add('Full-Time');
    if (freq.isNotEmpty) headerParts.add(_frequencyLabel(freq));
    if (interval != null) {
      headerParts.add('Every $interval ${_intervalSuffix(freq, interval)}');
    }
    // Add duration description (indefinite or range-based)
    final bool indefinite = (sch['indefinite'] == true);
    final String duration = _durationDescription(
      freq: freq,
      startIso: b.startTime,
      endIso: b.endTime,
      indefinite: indefinite,
    );
    if (duration.isNotEmpty) headerParts.add(duration);
    final header = headerParts.join(' • ');

    final chips = <Widget>[];
    if (windows.isNotEmpty) {
      // Sort by weekday 1..7
      final keys = windows.keys.toList()
        ..sort(
          (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
        );
      for (final k in keys) {
        final dayIdx = int.tryParse(k) ?? 0;
        final dayLabel = _weekdayName(dayIdx);
        final List items = windows[k] is List ? (windows[k] as List) : const [];
        if (items.isEmpty) continue;
        final ranges = items
            .map((it) {
              final m = (it is Map) ? it : {};
              final s = (m['start'] ?? '').toString();
              final e = (m['end'] ?? '').toString();
              return '$s–$e';
            })
            .join(', ');

        chips.add(
          Chip(
            label: Text(
              '$dayLabel: $ranges',
              style: const TextStyle(fontSize: 12),
            ),
            visualDensity: VisualDensity.compact,
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
                header.isNotEmpty ? header : 'Schedule',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
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

  String _frequencyLabel(String f) {
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

  String _intervalSuffix(String f, int n) {
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

  int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  String _weekdayName(int idx) {
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

  // Duration description for recurring/full_time based on start/end
  String _durationDescription({
    required String freq,
    required String? startIso,
    required String? endIso,
    required bool indefinite,
  }) {
    if (indefinite) return 'indefinite';
    if (startIso == null && endIso == null) return '';
    DateTime? s;
    DateTime? e;
    try {
      if (startIso != null) s = DateTime.parse(startIso);
    } catch (_) {}
    try {
      if (endIso != null) e = DateTime.parse(endIso);
    } catch (_) {}

    if (s == null && e == null) return '';
    if (s != null && e != null) {
      final diffDays = e.difference(s).inDays.abs();
      switch (freq) {
        case 'daily':
          final days = diffDays + 1; // inclusive range
          return '$days days';
        case 'weekly':
          final weeks = ((diffDays + 1) / 7).ceil();
          return '$weeks weeks';
        case 'monthly':
          final months = _monthDiff(s, e).abs();
          return months <= 1 ? '1 month' : '$months months';
        default:
          return '${diffDays + 1} days';
      }
    }
    // Open-ended one-side known
    if (s != null && e == null) {
      return 'from ${_d(s)}';
    }
    if (s == null && e != null) {
      return 'until ${_d(e)}';
    }
    return '';
  }

  int _monthDiff(DateTime a, DateTime b) {
    int months = (b.year - a.year) * 12 + (b.month - a.month);
    if (b.day < a.day) months -= 1;
    return months <= 0 ? 1 : months;
  }

  String _d(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatMetaValue(dynamic value) {
    if (value == null) return '';

    if (value is bool) {
      return value ? 'yes'.tr : 'no'.tr;
    } else if (value is List) {
      return value.map((item) => item.toString().tr).join(', ');
    } else {
      return value.toString().tr;
    }
  }
}
