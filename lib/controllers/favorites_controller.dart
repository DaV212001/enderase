import 'package:dio/dio.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/storage_config.dart';
import '../models/provider.dart';

class FavoritesController extends GetxController {
  // Results
  var providers = <Provider>[].obs;
  final ScrollController scrollController = ScrollController();

  // Loading states
  var loadingProviders = ApiCallStatus.holding.obs; // for initial / refresh
  var loadingMore = ApiCallStatus.holding.obs; // for pagination
  var removingProvider =
      <int, bool>{}.obs; // track which provider is being removed

  // Error
  var errorProviderFetching = ErrorData(title: '', body: '', image: '').obs;

  // Pagination
  int _page = 1;
  int _perPage = 15;
  bool hasMore = true;

  // Base path
  final String _basePath = '/api/v1/client/bookmark';

  @override
  void onInit() {
    fetchFavoritedProviders(refresh: true);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          hasMore &&
          loadingMore.value != ApiCallStatus.loading) {
        loadMoreProviders();
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

  /// Fetch bookmarked providers. If [refresh] is true the list is replaced and page resets to 1.
  Future<void> fetchFavoritedProviders({bool refresh = false}) async {
    try {
      if (refresh) {
        loadingProviders.value = ApiCallStatus.loading;
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
          final List newItems = (response.data['data'] as List?) ?? [];
          final parsed = newItems.map((e) => Provider.fromJson(e)).toList();

          if (refresh) {
            providers.value = parsed;
            loadingProviders.value = ApiCallStatus.success;
          } else {
            providers.addAll(parsed);
            loadingMore.value = ApiCallStatus.success;
          }

          // update pagination info
          final links = response.data['links'];
          hasMore = links != null && links['next'] != null;

          // if server gives meta, optionally sync page
          final meta = response.data['meta'];
          if (meta != null && meta['current_page'] != null) {
            _page = meta['current_page'];
          }
        },
        onFailure: (error, response) async {
          // roll back page increment if load more failed
          if (!refresh) {
            _page = (_page > 1) ? _page - 1 : 1;
            loadingMore.value = ApiCallStatus.error;
          } else {
            loadingProviders.value = ApiCallStatus.error;
          }

          errorProviderFetching.value = await ErrorUtil.getErrorData(
            error.toString(),
          );
        },
      );
    } catch (e) {
      // catch unexpected errors
      if (refresh) {
        loadingProviders.value = ApiCallStatus.error;
      } else {
        loadingMore.value = ApiCallStatus.error;
      }
      errorProviderFetching.value = await ErrorUtil.getErrorData(e.toString());
    }
  }

  /// Convenience method to trigger loading the next page (used by scroll listener)
  Future<void> loadMoreProviders() async {
    if (!hasMore) return;
    // avoid duplicate calls
    if (loadingMore.value == ApiCallStatus.loading) return;
    await fetchFavoritedProviders(refresh: false);
  }

  /// Remove provider from favorites
  Future<void> removeFromFavorites(int providerId) async {
    try {
      removingProvider[providerId] = true;

      await DioService.dioDelete(
        path: '/api/v1/client/bookmark/provider',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
          },
        ),
        data: {'provider_id': providerId},
        onSuccess: (response) {
          // Remove provider from local list
          providers.removeWhere((provider) => provider.id == providerId);
          removingProvider[providerId] = false;
          fetchFavoritedProviders(refresh: true);
          // Show success message
          Get.snackbar(
            'Success',
            'Provider removed from favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        onFailure: (error, response) async {
          removingProvider[providerId] = false;

          // Show error message
          Get.snackbar(
            'Error',
            'Failed to remove provider from favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      removingProvider[providerId] = false;

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to remove provider from favorites',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Refresh the favorites list
  Future<void> refreshFavorites() async {
    await fetchFavoritedProviders(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
