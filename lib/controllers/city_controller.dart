import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/setup_files/error_utils.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:get/get.dart';

import '../../models/city.dart'; // your City model with name getter

class CityController extends GetxController {
  var cities = <City>[].obs;
  var cityLoading = ApiCallStatus.holding.obs;
  var cityError = ErrorData(title: '', body: '', image: '').obs;
  var selectedCityId = 0.obs;

  @override
  void onInit() {
    fetchCities();
    super.onInit();
  }

  void fetchCities() async {
    cityLoading.value = ApiCallStatus.loading;
    await DioService.dioGet(
      path: '/api/v1/city',
      onSuccess: (response) {
        cities.value = (response.data['data'] as List)
            .map((city) => City.fromJson(city))
            .toList();
        cityLoading.value = ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        cityError.value = await ErrorUtil.getErrorData(response.toString());
        cityLoading.value = ApiCallStatus.error;
        await errorReport(response);
      },
    );
  }
}
