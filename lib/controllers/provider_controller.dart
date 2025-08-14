import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/provider.dart';

class ProviderController extends GetxController {
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

  @override
  void onInit() {
    fetchProviders(refresh: true);
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

    // always include categories
    params['include'] = 'categories';
    params['sort'] = '-rating';

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
}
