import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/provider.dart';

class SearchScreenController extends GetxController {
  // Results
  var providers = <Provider>[].obs;
  final ScrollController scrollController = ScrollController();
  // Loading states
  var loadingProviders = ApiCallStatus.holding.obs; // for initial / refresh
  var loadingMore = ApiCallStatus.holding.obs; // for pagination

  // Error
  var errorProviderFetching = ErrorData(title: '', body: '', image: '').obs;

  // Pagination
  int _page = 1;
  int _perPage = 15;
  bool hasMore = true;

  // Base path
  final String _basePath = '/api/v1/client/provider';

  // Filters (you can set these directly or use the `applyFilters` helper)
  final RxString filterFirstName = ''.obs;
  final RxString filterMiddleName = ''.obs;
  final Rxn<int> filterCityId = Rxn<int>();
  final Rxn<int> filterRating = Rxn<int>();
  final Rxn<int> filterWorkRadius = Rxn<int>();
  final Rxn<int> filterCategoryId = Rxn<int>();
  final RxString sort = ''.obs;

  @override
  void onInit() {
    if (Get.arguments != null) {
      applyFilters(categoryId: Get.arguments);
    } else {
      fetchProviders(refresh: true);
    }
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

  /// Build the query string from the active filters and page
  String _buildQuery({required int page}) {
    final Map<String, String> params = {};

    if (filterFirstName.value.trim().isNotEmpty) {
      params['filter[first_name]'] = filterFirstName.value.trim();
    }
    if (filterMiddleName.value.trim().isNotEmpty) {
      params['filter[middle_name]'] = filterMiddleName.value.trim();
    }
    if (filterCityId.value != null) {
      params['filter[city_id]'] = filterCityId.value.toString();
    }
    if (filterRating.value != null) {
      params['filter[rating]'] = filterRating.value.toString();
    }
    if (filterWorkRadius.value != null) {
      params['filter[work_radius]'] = filterWorkRadius.value.toString();
    }
    if (filterCategoryId.value != null) {
      params['filter[category_id]'] = filterCategoryId.value.toString();
    }
    if (sort.value.trim().isNotEmpty) {
      params['sort'] = sort.value.trim();
    }

    // always include categories
    params['include'] = 'categories';

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

  /// Fetch providers. If [refresh] is true the list is replaced and page resets to 1.
  Future<void> fetchProviders({bool refresh = false}) async {
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
    await fetchProviders(refresh: false);
  }

  /// Apply filters and refresh the list. Any null value means "no change".
  Future<void> applyFilters({
    String? firstName,
    String? middleName,
    int? cityId,
    int? rating,
    int? workRadius,
    int? categoryId,
    String? sortBy,
  }) async {
    if (firstName != null) filterFirstName.value = firstName;
    if (middleName != null) filterMiddleName.value = middleName;
    if (cityId != null) filterCityId.value = cityId;
    if (rating != null) filterRating.value = rating;
    if (workRadius != null) filterWorkRadius.value = workRadius;
    if (categoryId != null) filterCategoryId.value = categoryId;
    if (sortBy != null) sort.value = sortBy;

    await fetchProviders(refresh: true);
  }

  /// Clear all filters and refresh
  Future<void> clearFiltersAndRefresh() async {
    filterFirstName.value = '';
    filterMiddleName.value = '';
    filterCityId.value = null;
    filterRating.value = null;
    filterWorkRadius.value = null;
    filterCategoryId.value = null;
    sort.value = '';

    await fetchProviders(refresh: true);
  }

  /// Clear a specific filter by name and refresh
  Future<void> clearFilter(String filterName) async {
    switch (filterName) {
      case 'firstName':
        filterFirstName.value = '';
        break;
      case 'middleName':
        filterMiddleName.value = '';
        break;
      case 'city':
        filterCityId.value = null;
        break;
      case 'rating':
        filterRating.value = null;
        break;
      case 'radius':
        filterWorkRadius.value = null;
        break;
      case 'category':
        filterCategoryId.value = null;
        break;
      case 'sort':
        sort.value = '';
        break;
    }
    await fetchProviders(refresh: true);
  }
}
