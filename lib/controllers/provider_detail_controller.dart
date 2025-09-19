import 'package:dio/dio.dart';
import 'package:enderase/controllers/favorites_controller.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:get/get.dart';

import '../../models/provider.dart';
import '../../models/rating.dart';
import '../config/storage_config.dart';

class ProviderDetailController extends GetxController {
  var provider = Provider().obs;
  var providerLoading = ApiCallStatus.holding.obs;
  var providerError = ErrorData(title: '', body: '', image: '').obs;
  var ratingsLoading = ApiCallStatus.holding.obs;
  var ratings = <RatingModel>[].obs;

  // Bookmark state
  var isBookmarked = false.obs;
  var bookmarkLoading = false.obs;

  int get providerId => provider.value.id ?? Get.arguments;

  @override
  void onInit() {
    fetchProvider();
    super.onInit();
  }

  void fetchProvider() async {
    // check bookmark status after fetching provider
    checkBookmark();

    providerLoading.value = ApiCallStatus.loading;

    await DioService.dioGet(
      path: '/api/v1/client/provider/${Get.arguments}',
      onSuccess: (response) {
        provider.value = Provider.fromJson(response.data['data']);
        providerLoading.value = ApiCallStatus.success;
        fetchRatings();
      },
      onFailure: (error, response) async {
        providerError.value = await ErrorUtil.getErrorData(response.toString());
        providerLoading.value = ApiCallStatus.error;
        await errorReport(response);
      },
    );
  }

  // Public reviews: no auth required
  Future<void> fetchRatings() async {
    ratingsLoading.value = ApiCallStatus.loading;
    await DioService.dioGet(
      path: '/api/v1/client/provider/${providerId}/rate',
      onSuccess: (response) {
        final list = (response.data['data']['data'] as List?) ?? [];
        ratings.value = list.map((e) => RatingModel.fromJson(e)).toList();
        ratingsLoading.value = ApiCallStatus.success;
      },
      onFailure: (err, resp) async {
        ratingsLoading.value = ApiCallStatus.error;
      },
    );
  }

  // Check if bookmarked
  void checkBookmark() async {
    bookmarkLoading.value = true;
    try {
      await DioService.dioGet(
        path: '/api/v1/client/bookmark/$providerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
          },
        ),
        onSuccess: (response) {
          isBookmarked.value = response.data['data']['exists'] ?? false;
          bookmarkLoading.value = false;
        },
        onFailure: (error, response) async {
          isBookmarked.value = false; // fallback
          bookmarkLoading.value = false;
          await errorReport(response);
        },
      );
    } catch (e) {
      isBookmarked.value = false; // fallback
      bookmarkLoading.value = false;
    }
  }

  // Optimistic toggle
  void toggleBookmark() async {
    if (bookmarkLoading.value) return;

    final oldState = isBookmarked.value;
    isBookmarked.value = !oldState; // optimistic update
    bookmarkLoading.value = true;

    try {
      if (isBookmarked.value) {
        await DioService.dioPost(
          path: '/api/v1/client/bookmark/provider',
          data: {"provider_id": provider.value.id},
          options: Options(
            headers: {
              'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
            },
          ),
          onSuccess: (response) async {
            if (Get.isRegistered<FavoritesController>()) {
              Get.find<FavoritesController>().fetchFavoritedProviders(
                refresh: true,
              );
            }
          },
          onFailure: (error, response) async {
            // rollback state
            isBookmarked.value = oldState;
          },
        );
      } else {
        await DioService.dioDelete(
          path: '/api/v1/client/bookmark/provider',
          data: {"provider_id": provider.value.id},
          options: Options(
            headers: {
              'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
            },
          ),
          onSuccess: (response) {
            if (Get.isRegistered<FavoritesController>()) {
              Get.find<FavoritesController>().fetchFavoritedProviders(
                refresh: true,
              );
            }
          },
          onFailure: (error, response) async {
            // rollback state
            isBookmarked.value = oldState;
          },
        );
      }
    } catch (e) {
      // rollback state
      isBookmarked.value = oldState;

      // show error
      Get.snackbar('Could not update bookmark', 'Please try again.');
    } finally {
      bookmarkLoading.value = false;
    }
  }
}
