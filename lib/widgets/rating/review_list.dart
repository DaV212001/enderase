import 'package:enderase/controllers/provider_detail_controller.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewList extends StatelessWidget {
  const ReviewList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProviderDetailController>();
    return Obx(() {
      if (c.ratingsLoading.value == ApiCallStatus.loading) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (c.ratings.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('no_reviews_yet'.tr),
        );
      }
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: c.ratings.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final r = c.ratings[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.15),
              child: Text(
                '${r.rating}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            title: Text(r.comment.isEmpty ? 'no_comment'.tr : r.comment),
            subtitle: Text(_format(r.createdAt)),
          );
        },
      );
    });
  }

  String _format(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
