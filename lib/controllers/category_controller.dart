import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/category.dart';

class CategoryController extends GetxController {
  var categories = <Category>[].obs;
  var loadingCategory = ApiCallStatus.holding.obs;
  var errorCategoryFetching = ErrorData(title: '', body: '', image: '').obs;

  final PageController pageController = PageController();
  var currentPage = 0.obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  void fetchCategories() async {
    loadingCategory.value = ApiCallStatus.loading;
    await DioService.dioGet(
      path: '/api/v1/category',
      onSuccess: (response) {
        loadingCategory.value = ApiCallStatus.success;
        categories.value = (response.data['data'] as List)
            .map((e) => Category.fromJson(e))
            .toList();
      },
      onFailure: (error, response) async {
        loadingCategory.value = ApiCallStatus.error;
        errorCategoryFetching.value = await ErrorUtil.getErrorData(
          error.toString(),
        );
      },
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
