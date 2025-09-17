import 'package:dio/dio.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:get/get.dart';

import '../config/storage_config.dart';
import '../models/booking.dart';

class BookingDetailController extends GetxController {
  final int bookingId;
  BookingDetailController({required this.bookingId});

  var loading = ApiCallStatus.holding.obs;
  var error = ErrorData(title: '', body: '', image: '').obs;
  var booking = Rxn<Booking>();

  // Rating form state
  var ratingValue = 0.obs; // 1..5
  var ratingComment = ''.obs;
  var submittingRating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    loading.value = ApiCallStatus.loading;
    await DioService.dioGet(
      path: '/api/v1/client/booking/$bookingId',
      options: Options(headers: {
        'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
      }),
      onSuccess: (response) {
        final data = response.data['data'];
        booking.value = Booking.fromJson(data);
        loading.value = ApiCallStatus.success;
      },
      onFailure: (err, resp) async {
        error.value = await ErrorUtil.getErrorData(resp.toString());
        loading.value = ApiCallStatus.error;
      },
    );
  }

  bool get canRateProvider {
    final b = booking.value;
    if (b == null) return false;
    final status = (b.status ?? '').toLowerCase();
    return status == 'confirmed' || status == 'active' || status == 'completed';
  }

  Future<void> submitRating() async {
    if (!canRateProvider) return;
    if ((ratingValue.value) < 1 || ratingComment.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide rating and comment');
      return;
    }
    submittingRating.value = true;
    try {
      await DioService.dioPost(
        path: '/api/v1/client/rate',
        data: {
          'provider_id': booking.value?.providerId ?? booking.value?.provider?['id'],
          'rating': ratingValue.value,
          'comment': ratingComment.value.trim(),
        },
        options: Options(headers: {
          'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
        }),
        onSuccess: (resp) {
          Get.snackbar('Success', 'Thanks for your review!');
        },
        onFailure: (err, resp) async {
          final e = await ErrorUtil.getErrorData(resp.toString());
          Get.snackbar(e.title, e.body);
        },
      );
    } finally {
      submittingRating.value = false;
    }
  }
}


