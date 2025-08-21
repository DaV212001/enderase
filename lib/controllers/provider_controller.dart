import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:get/get.dart';

import '../models/provider.dart';

class ProviderController extends GetxController {
  static String tag = 'provider';

  // Results
  var providers = <Provider>[].obs;
  // Loading states
  var loadingProviders = ApiCallStatus.holding.obs; // for initial / refresh
  var loadingMore = ApiCallStatus.holding.obs; // for pagination

  // Error
  var errorProviderFetching = ErrorData(title: '', body: '', image: '').obs;

  // Pagination
  int _page = 1;
  final int _perPage = 15;
  bool hasMore = true;

  // Base path
  final String _basePath = '/api/v1/client/provider';

  @override
  void onInit() {
    fetchProviders(refresh: true);
    fetchTopRatedProviders();
    fetchProfessionalProviders();
    super.onInit();
  }

  /// Build the query string from the active filters and page
  String _buildQuery({required int page}) {
    final Map<String, String> params = {};

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

  final topRatedProviders = <Provider>[].obs;
  final loadingTopRatedProviders = ApiCallStatus.holding.obs;
  final errorTopRatedProviders = Rxn<ErrorData>();

  final professionalProviders = <Provider>[].obs;
  final loadingProfessionalProviders = ApiCallStatus.holding.obs;
  final errorProfessionalProviders = Rxn<ErrorData>();

  Future<void> fetchTopRatedProviders() async {
    try {
      loadingTopRatedProviders.value = ApiCallStatus.loading;

      final path = '$_basePath?include=categories&sort=-rating';

      await DioService.dioGet(
        path: path,
        onSuccess: (response) {
          final List newItems = (response.data['data'] as List?) ?? [];
          final parsed = newItems.map((e) => Provider.fromJson(e)).toList();

          topRatedProviders.value = parsed;
          loadingTopRatedProviders.value = ApiCallStatus.success;
        },
        onFailure: (error, response) async {
          loadingTopRatedProviders.value = ApiCallStatus.error;
          errorTopRatedProviders.value = await ErrorUtil.getErrorData(
            error.toString(),
          );
        },
      );
    } catch (e) {
      loadingTopRatedProviders.value = ApiCallStatus.error;
      errorTopRatedProviders.value = await ErrorUtil.getErrorData(e.toString());
    }
  }

  Future<void> fetchProfessionalProviders() async {
    try {
      loadingProfessionalProviders.value = ApiCallStatus.loading;

      final path = '$_basePath?include=certifications,categories';

      await DioService.dioGet(
        path: path,
        onSuccess: (response) {
          final List newItems = (response.data['data'] as List?) ?? [];
          final parsed = newItems
              .map((e) => Provider.fromJson(e))
              .where((provider) => (provider.certifications ?? []).isNotEmpty)
              .toList();

          professionalProviders.value = parsed;
          loadingProfessionalProviders.value = ApiCallStatus.success;
        },
        onFailure: (error, response) async {
          loadingProfessionalProviders.value = ApiCallStatus.error;
          errorProfessionalProviders.value = await ErrorUtil.getErrorData(
            error.toString(),
          );
        },
      );
    } catch (e) {
      loadingProfessionalProviders.value = ApiCallStatus.error;
      errorProfessionalProviders.value = await ErrorUtil.getErrorData(
        e.toString(),
      );
    }
  }
}
