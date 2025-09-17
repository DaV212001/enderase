import 'package:get/get.dart';

class Booking {
  final int? id;
  final int? clientId;
  final int? providerId;
  final int? categoryId;
  final String? startTime;
  final String? endTime;
  final String? notes;
  final Map<String, dynamic>? meta;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  // Dynamic nested payloads
  final Map<String, dynamic>? schedule; // one_time / recurring / full_time
  final Map<String, dynamic>? provider; // nested provider object
  final Map<String, dynamic>? category; // nested category object

  Booking({
    this.id,
    this.clientId,
    this.providerId,
    this.categoryId,
    this.startTime,
    this.endTime,
    this.notes,
    this.meta,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.schedule,
    this.provider,
    this.category,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Pull nested objects if present
    final Map<String, dynamic>? schedule =
        json['schedule'] != null ? Map<String, dynamic>.from(json['schedule']) : null;
    final Map<String, dynamic>? provider =
        json['provider'] != null ? Map<String, dynamic>.from(json['provider']) : null;
    final Map<String, dynamic>? category =
        json['category'] != null ? Map<String, dynamic>.from(json['category']) : null;

    // Prefer schedule one-time fields when available
    String? startTime;
    String? endTime;
    if (schedule != null) {
      if (schedule['one_time_start'] != null) {
        startTime = schedule['one_time_start'];
      }
      if (schedule['one_time_end'] != null) {
        endTime = schedule['one_time_end'];
      }
    }

    return Booking(
      id: json['id'],
      clientId: json['client_id'] is String
          ? int.tryParse(json['client_id'])
          : json['client_id'],
      providerId: json['provider_id'] is String
          ? int.tryParse(json['provider_id'])
          : json['provider_id'],
      categoryId: json['category_id'] is String
          ? int.tryParse(json['category_id'])
          : json['category_id'],
      startTime: startTime ?? json['start_date'],
      endTime: endTime ?? json['end_date'],
      notes: json['notes'],
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'])
          : null,
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      schedule: schedule,
      provider: provider,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'client_id': clientId,
    'provider_id': providerId,
    'category_id': categoryId,
    'start_time': startTime,
    'end_time': endTime,
    'notes': notes,
    'meta': meta,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'schedule': schedule,
    'provider': provider,
    'category': category,
  };

  // Helper getters for display
  String get formattedStartTime {
    if (startTime == null) return '-';
    try {
      final dateTime = DateTime.parse(startTime!);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime!;
    }
  }

  String get formattedEndTime {
    if (endTime == null) return '-';
    try {
      final dateTime = DateTime.parse(endTime!);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return endTime!;
    }
  }

  String get statusDisplay {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'pending'.tr;
      case 'active':
        return 'confirmed'.tr; // Map Active -> Confirmed for display
      case 'confirmed':
        return 'confirmed'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      case 'completed':
        return 'completed'.tr;
      default:
        return status ?? '';
    }
  }

  String get statusColor {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'active':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'completed':
        return 'blue';
      default:
        return 'grey';
    }
  }

  // Meta data is handled dynamically in the UI with translations

  String get providerDisplayName {
    if (provider == null) return (providerId ?? '').toString();
    final first = provider!['first_name'] ?? '';
    final middle = provider!['middle_name'] ?? '';
    final last = provider!['last_name'] ?? '';
    return [first, middle, last]
        .where((p) => p != null && p.toString().trim().isNotEmpty)
        .join(' ')
        .trim();
  }

  String get categoryDisplayName {
    if (category == null) return (categoryId ?? '').toString();
    return (category!['category'] ?? '').toString();
  }
}
