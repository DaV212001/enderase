import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:enderase/models/city.dart';
import 'package:enderase/models/sub_city.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../config/storage_config.dart';
import '../constants/pages.dart';
import '../models/user.dart';
import '../setup_files/error_utils.dart';
import '../setup_files/templates/dio_template.dart';

class UserController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static Rx<User> user = const User(
    firstName: 'Anonymous',
    lastName: 'Anonymous',
    // phone: '251987654321',
    // email: 'anonymous@gmail.com'
  ).obs;
  static RxBool isLoggedIn = false.obs;

  late Rx<TabController> tabController;
  var tabIndex = 0.obs;
  var loggingIn = false.obs;
  var signingUp = false.obs;
  final formKey = GlobalKey<FormState>();
  final loginKey = GlobalKey<FormState>();
  TextEditingController passwordTextEditingController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  FocusNode firstnameFocusNode = FocusNode();

  TextEditingController fanNumberController = TextEditingController();
  FocusNode lastnameFocusNode = FocusNode();

  TextEditingController phoneController = TextEditingController();
  FocusNode phoneFocusNode = FocusNode();

  TextEditingController emailAddressSignUpController = TextEditingController();
  FocusNode emailAddressSignUpFocusNode = FocusNode();

  TextEditingController passwordSignUpController = TextEditingController();
  FocusNode passwordSignUpFocusNode2 = FocusNode();

  TextEditingController secondaryPhoneController = TextEditingController();
  FocusNode confirmPasswordSignUpFocusNode2 = FocusNode();

  TextEditingController emailorPhoneSignInController = TextEditingController();
  FocusNode emailAddressSignInFocusNode = FocusNode();

  TextEditingController passwordSignInController = TextEditingController();
  FocusNode passwordSignInFocusNode2 = FocusNode();

  TextEditingController landlinePhoneController = TextEditingController();
  FocusNode landlinePhoneFocusNode2 = FocusNode();

  TextEditingController cityController = TextEditingController();
  FocusNode cityFocusNode2 = FocusNode();

  TextEditingController subCityController = TextEditingController();
  FocusNode subCityFocusNode2 = FocusNode();

  TextEditingController woredaController = TextEditingController();
  FocusNode woredaFocusNode2 = FocusNode();

  TextEditingController houseNumberController = TextEditingController();
  FocusNode houseNumberFocusNode2 = FocusNode();

  Rx<File?> profilePhotoFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this).obs;
    fetchCities();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profilePhotoFile.value = File(pickedFile.path);
    }
  }

  static getLoggedInUser() {
    User userTemp = const User();
    bool status = ConfigPreference.getUserToken() != null;
    print("Logged in status = $status");
    if (status == true) {
      final userData = ConfigPreference.getUserData();

      print('FETCH LOGGED IN USER: $userData');
      final user = User.fromJson(userData ?? {});
      userTemp = user;
      isLoggedIn.value = true;
      isLoggedIn.refresh();
      Logger().d('Logged in: ${isLoggedIn.value}');
    } else {
      isLoggedIn.value = false;
    }
    user.value = userTemp;
    user.refresh();
  }

  var cities = <City>[].obs;
  var cityLoading = ApiCallStatus.holding.obs;
  var cityError = ErrorData(title: '', body: '', image: '').obs;
  var selectedCityId = 0.obs;

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

  var subCities = <SubCity>[].obs;
  var subCityLoading = ApiCallStatus.holding.obs;
  var subCityError = ErrorData(title: '', body: '', image: '').obs;
  var selectedSubCityId = 0.obs;

  void fetchSubCities() async {
    subCityLoading.value = ApiCallStatus.loading;
    await DioService.dioGet(
      path: '/api/v1/subcity',
      data: {'city_id': selectedCityId.value},
      onSuccess: (response) {
        subCities.value = (response.data['data'] as List)
            .map((city) => SubCity.fromJson(city))
            .toList();
        subCityLoading.value = ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        subCityError.value = await ErrorUtil.getErrorData(response.toString());
        subCityLoading.value = ApiCallStatus.error;
        await errorReport(response);
      },
    );
  }

  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();
  final step3Key = GlobalKey<FormState>();
  final step4Key = GlobalKey<FormState>();
  bool validateCurrentStep() {
    switch (tabIndex.value) {
      case 0:
        return step1Key.currentState?.validate() ?? false;
      case 1:
        return step2Key.currentState?.validate() ?? false;
      case 2:
        return step3Key.currentState?.validate() ?? false;
      case 3:
        // Last step: must have profile picture + pass validation
        bool formValid = step4Key.currentState?.validate() ?? false;
        bool pictureChosen = profilePhotoFile.value != null;
        if (!pictureChosen) {
          Get.snackbar("Error", "Please select a profile picture.");
        }
        return formValid && pictureChosen;
      default:
        return true;
    }
  }

  void signUp() async {
    if (validateCurrentStep() == false) return;

    final formDataFields = {
      'first_name': nameController.text.split(' ')[0].trim(),
      'middle_name': nameController.text.split(' ')[1].trim(),
      'last_name': nameController.text.split(' ')[2].trim(),
      'password': passwordSignUpController.text.trim(),
      'email': emailAddressSignUpController.text.trim(),
      'fan_number': fanNumberController.text.trim(),
      'primary_phone': phoneController.text.trim(),
      'secondary_phone': secondaryPhoneController.text.trim(),
      'landline_phone': landlinePhoneController.text.trim(),
      'city_id': selectedCityId.toString().trim(),
      'subcity_id': selectedSubCityId.toString().trim(),
      'woreda': int.parse(woredaController.text.trim()),
      'house_number': int.parse(houseNumberController.text.trim()),
    };

    Map<String, dio.MultipartFile>? files = {};

    if (profilePhotoFile.value != null) {
      final fileName = profilePhotoFile.value!.path.split('/').last;
      files['profile_picture'] = await dio.MultipartFile.fromFile(
        profilePhotoFile.value!.path,
        filename: fileName,
      );
    }

    signingUp.value = true;

    await DioService.dioPostFormData(
      path: "/api/v1/client/auth/signup",
      formDataFields: formDataFields,
      files: files,
      onSuccess: (response) async {
        final data = response.data;

        String token = data['data']['token'];
        ConfigPreference.setUserToken(token);
        ConfigPreference.setUserData(data['data']['client']);

        User userTemp = User.fromJson(data['data']['client']);
        user.value = userTemp;
        signingUp.value = false;
        Get.snackbar('Success', 'You have signed up successfully');
        Get.offNamed(AppRoutes.mainLayoutRoute);
      },
      onFailure: (error, response) async {
        signingUp.value = false;
        await errorReport(response);
      },
    );
  }

  void logIn() async {
    if (loginKey.currentState!.validate() == false) return;
    // try {
    final requestData = {
      "email_phone": emailorPhoneSignInController.text,
      "password": passwordSignInController.text,
      // "provider": "google",
    };
    loggingIn.value = true;
    await DioService.dioPost(
      path: "/api/v1/client/auth/login",
      data: requestData,
      onSuccess: (response) async {
        final data = response.data;

        String token = data['data']['token'];
        ConfigPreference.setUserToken(token);
        ConfigPreference.setUserData(data['data']['client']);

        User userTemp = User.fromJson(data['data']['client']);
        user.value = userTemp;
        Get.offNamed(AppRoutes.mainLayoutRoute);
        loggingIn.value = false;
        // signingUp.value = false;
      },
      onFailure: (error, response) async {
        loggingIn.value = false;
        await errorReport(response);
      },
    );
  }
}
