import 'package:dio/dio.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/storage_config.dart';
import '../models/booking.dart';

class BookingsController extends GetxController {
  // Results
  var bookings = <Booking>[].obs;
  final ScrollController scrollController = ScrollController();

  // Loading states
  var loadingBookings = ApiCallStatus.holding.obs; // for initial / refresh
  var loadingMore = ApiCallStatus.holding.obs; // for pagination

  // Error
  var errorBookingFetching = ErrorData(title: '', body: '', image: '').obs;

  // Pagination
  int _page = 1;
  int _perPage = 15;
  bool hasMore = true;

  // Base path
  final String _basePath = '/api/v1/client/booking';

  @override
  void onInit() {
    fetchBookings(refresh: true);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          hasMore &&
          loadingMore.value != ApiCallStatus.loading) {
        loadMoreBookings();
      }
    });
    super.onInit();
  }

  /// Build the query string for pagination
  String _buildQuery({required int page}) {
    final Map<String, String> params = {};

    // pagination
    params['page'] = page.toString();
    params['per_page'] = _perPage.toString();

    // encode
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
  }

  /// Fetch bookings. If [refresh] is true the list is replaced and page resets to 1.
  Future<void> fetchBookings({bool refresh = false}) async {
    try {
      if (refresh) {
        loadingBookings.value = ApiCallStatus.loading;
        _page = 1;
        hasMore = true;
      } else {
        // loading more
        loadingMore.value = ApiCallStatus.loading;
        _page += 1; // move to next page
      }

      final path = '$_basePath?${_buildQuery(page: _page)}';

      await DioService.dioGet(
        path: path,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
          },
        ),
        onSuccess: (response) {
          // API returns a top-level object with pagination keys
          // data.data is the array of bookings
          final dynamic top = response.data['data'] ?? response.data;
          final List newItems = (top is Map && top['data'] is List)
              ? (top['data'] as List)
              : (response.data['data'] as List?) ?? [];
          final parsed = newItems.map((e) => Booking.fromJson(e)).toList();

          if (refresh) {
            bookings.value = parsed;
            loadingBookings.value = ApiCallStatus.success;
          } else {
            bookings.addAll(parsed);
            loadingMore.value = ApiCallStatus.success;
          }

          // update pagination info (support both shapes)
          final links = response.data['links'] ?? top['links'];
          final meta = response.data['meta'] ?? top['meta'];
          hasMore = links != null && links['next'] != null;
          if (meta != null && meta['current_page'] != null) {
            _page = meta['current_page'];
          }
          bookings.sort(
            (a, b) =>
                DateTime.parse(
                  a.createdAt ?? '',
                ).isBefore(DateTime.parse(b.createdAt ?? ''))
                ? 1
                : -1,
          );
        },
        onFailure: (error, response) async {
          // roll back page increment if load more failed
          if (!refresh) {
            _page = (_page > 1) ? _page - 1 : 1;
            loadingMore.value = ApiCallStatus.error;
          } else {
            loadingBookings.value = ApiCallStatus.error;
          }

          errorBookingFetching.value = await ErrorUtil.getErrorData(
            error.toString(),
          );
        },
      );
    } catch (e) {
      // catch unexpected errors
      if (refresh) {
        loadingBookings.value = ApiCallStatus.error;
      } else {
        loadingMore.value = ApiCallStatus.error;
      }
      errorBookingFetching.value = await ErrorUtil.getErrorData(e.toString());
    }
  }

  /// Convenience method to trigger loading the next page (used by scroll listener)
  Future<void> loadMoreBookings() async {
    if (!hasMore) return;
    // avoid duplicate calls
    if (loadingMore.value == ApiCallStatus.loading) return;
    await fetchBookings(refresh: false);
  }

  /// Refresh the bookings list
  Future<void> refreshBookings() async {
    await fetchBookings(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
