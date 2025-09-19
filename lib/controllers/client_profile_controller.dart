import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:enderase/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/storage_config.dart';
import '../models/city.dart';
import '../models/sub_city.dart';
import '../models/user.dart';
import '../setup_files/error_utils.dart';
import '../setup_files/templates/dio_template.dart';

class ClientProfileController extends GetxController {
  final loading = false.obs;
  final saving = false.obs;
  final changingPassword = false.obs;
  final uploadingPhoto = false.obs;

  final profile = const User().obs;

  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  // Text controllers
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final fanNumberController = TextEditingController();
  final primaryPhoneController = TextEditingController();
  final secondaryPhoneController = TextEditingController();
  final landlinePhoneController = TextEditingController();
  final cityController =
      TextEditingController(); // for display-only when needed
  final subcityController = TextEditingController();
  final woredaController = TextEditingController();
  final houseNumberController = TextEditingController();

  // Password inputs
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final logoutOthers = false.obs;

  // Photo
  final pickedImage = Rx<File?>(null);

  // City / Subcity selectors
  final cities = <City>[].obs;
  final subCities = <SubCity>[].obs;
  final selectedCityId = Rx<int?>(null);
  final selectedSubCityId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchCities();
  }

  Future<void> fetchProfile() async {
    loading.value = true;
    await DioService.dioGet(
      path: '/api/v1/client/profile',
      options: d.Options(
        headers: {'Authorization': 'Bearer ${ConfigPreference.getUserToken()}'},
      ),
      onSuccess: (response) {
        final data = response.data['data']['client'] as Map<String, dynamic>;
        final user = User.fromJson(data);
        profile.value = user;
        // seed controllers
        firstNameController.text =
            '${user.firstName ?? ''} ${user.middleName ?? ''} ${user.lastName ?? ''}';
        middleNameController.text = user.middleName ?? '';
        lastNameController.text = user.lastName ?? '';
        fanNumberController.text = user.fanNumber ?? '';
        primaryPhoneController.text = user.primaryPhone ?? '';
        secondaryPhoneController.text = user.secondaryPhone ?? '';
        landlinePhoneController.text = user.landlinePhone ?? '';
        cityController.text = user.city ?? '';
        subcityController.text = user.subcity ?? '';
        woredaController.text = (user.woreda ?? '').toString();
        houseNumberController.text = user.houseNumber ?? '';
        loading.value = false;
        // match selected city by name after cities list loads
        if (cities.isNotEmpty) {
          _syncSelectedCityByName();
        }
      },
      onFailure: (error, response) async {
        loading.value = false;
        await errorReport(response);
      },
    );
  }

  Future<void> fetchCities() async {
    await DioService.dioGet(
      path: '/api/v1/city',
      onSuccess: (response) {
        cities.value = (response.data['data'] as List)
            .map((e) => City.fromJson(e))
            .toList();
        _syncSelectedCityByName();
      },
      onFailure: (error, response) async {
        await errorReport(response);
      },
    );
  }

  void _syncSelectedCityByName() {
    if ((profile.value.city ?? '').isEmpty) return;
    final String currentCityName = profile.value.city!;
    final City? matched = cities.firstWhereOrNull(
      (c) =>
          (c.nameEn ?? '').toLowerCase() == currentCityName.toLowerCase() ||
          (c.nameAm ?? '').toLowerCase() == currentCityName.toLowerCase(),
    );
    if (matched != null) {
      selectedCityId.value = matched.id;
      fetchSubCities();
    }
  }

  Future<void> fetchSubCities() async {
    if (selectedCityId.value == null) {
      subCities.clear();
      selectedSubCityId.value = null;
      return;
    }
    await DioService.dioGet(
      path: '/api/v1/subcity',
      data: {'city_id': selectedCityId.value},
      onSuccess: (response) {
        subCities.value = (response.data['data'] as List)
            .map((e) => SubCity.fromJson(e))
            .toList();
        // sync existing profile subcity by name
        if ((profile.value.subcity ?? '').isNotEmpty) {
          final sub = subCities.firstWhereOrNull(
            (s) =>
                (s.nameEn ?? '').toLowerCase() ==
                    profile.value.subcity!.toLowerCase() ||
                (s.nameAm ?? '').toLowerCase() ==
                    profile.value.subcity!.toLowerCase(),
          );
          if (sub != null) selectedSubCityId.value = sub.id;
        }
      },
      onFailure: (error, response) async {
        await errorReport(response);
      },
    );
  }

  Map<String, dynamic> _diffBody() {
    final Map<String, dynamic> body = {};
    void addIfChanged(
      String key,
      String? controllerValue,
      String? currentValue,
    ) {
      if ((controllerValue ?? '').trim() != (currentValue ?? '').trim()) {
        body[key] = (controllerValue ?? '').trim();
      }
    }

    addIfChanged(
      'first_name',
      firstNameController.text.split(' ').first,
      profile.value.firstName,
    );
    addIfChanged(
      'middle_name',
      firstNameController.text.split(' ')[1],
      profile.value.middleName,
    );
    addIfChanged(
      'last_name',
      firstNameController.text.split(' ').last,
      profile.value.lastName,
    );
    addIfChanged(
      'fan_number',
      fanNumberController.text,
      profile.value.fanNumber,
    );
    addIfChanged(
      'primary_phone',
      primaryPhoneController.text,
      profile.value.primaryPhone,
    );
    addIfChanged(
      'secondary_phone',
      secondaryPhoneController.text,
      profile.value.secondaryPhone,
    );
    addIfChanged(
      'landline_phone',
      landlinePhoneController.text,
      profile.value.landlinePhone,
    );
    // if dropdowns are used, set from selected items' names
    final String? selectedCityName = _selectedCityName;
    final String? selectedSubCityName = _selectedSubCityName;
    addIfChanged(
      'city',
      selectedCityName ?? cityController.text,
      profile.value.city,
    );
    addIfChanged(
      'subcity',
      selectedSubCityName ?? subcityController.text,
      profile.value.subcity,
    );
    addIfChanged('woreda', woredaController.text, profile.value.woreda);
    addIfChanged(
      'house_number',
      houseNumberController.text,
      profile.value.houseNumber,
    );

    return body;
  }

  String? get _selectedCityName {
    if (selectedCityId.value == null) return null;
    final c = cities.firstWhereOrNull((e) => e.id == selectedCityId.value);
    return c?.name;
  }

  String? get _selectedSubCityName {
    if (selectedSubCityId.value == null) return null;
    final s = subCities.firstWhereOrNull(
      (e) => e.id == selectedSubCityId.value,
    );
    return s?.name;
  }

  Future<void> updateProfile() async {
    if (!(profileFormKey.currentState?.validate() ?? false)) return;
    final body = _diffBody();
    if (body.isEmpty) return;
    saving.value = true;
    await DioService.dioPatch(
      path: '/api/v1/client/profile',
      data: body,
      options: d.Options(
        headers: {'Authorization': 'Bearer ${ConfigPreference.getUserToken()}'},
      ),
      onSuccess: (response) {
        Get.snackbar('Success', 'Profile updated');
        // Update local cached user if returned
        if (response.data is Map &&
            (response.data['data']?['client']) != null) {
          final user = User.fromJson(response.data['data']['client']);
          profile.value = user;
          ConfigPreference.setUserData(response.data['data']['client']);

          User userTemp = User.fromJson(response.data['data']['client']);
          UserController.user.value = userTemp;
          UserController.user.refresh();
        }
        saving.value = false;
      },
      onFailure: (error, response) async {
        saving.value = false;
        await errorReport(response);
      },
    );
  }

  Future<void> changePassword() async {
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;
    changingPassword.value = true;
    final body = {
      'current_password': currentPasswordController.text,
      'new_password': newPasswordController.text,
      'new_password_confirmation': newPasswordController.text,
      'logout_other_devices': logoutOthers.value,
    };
    await DioService.dioPatch(
      path: '/api/v1/client/profile/change-password',
      data: body,
      options: d.Options(
        headers: {'Authorization': 'Bearer ${ConfigPreference.getUserToken()}'},
      ),
      onSuccess: (response) {
        Get.snackbar('Success', 'Password changed');
        changingPassword.value = false;
      },
      onFailure: (error, response) async {
        changingPassword.value = false;
        await errorReport(response);
      },
    );
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      pickedImage.value = File(file.path);
    }
  }

  Future<void> uploadProfilePicture() async {
    if (pickedImage.value == null) return;
    uploadingPhoto.value = true;
    final filename = pickedImage.value!.path.split('/').last;
    await DioService.dioPostFormData(
      path: '/api/v1/client/profile/change-profile-picture',
      formDataFields: const {},
      files: {
        'profile_picture': await d.MultipartFile.fromFile(
          pickedImage.value!.path,
          filename: filename,
        ),
      },
      options: d.Options(
        headers: {
          'Authorization': 'Bearer ${ConfigPreference.getUserToken()}',
          'Accept': 'application/json',
        },
      ),
      onSuccess: (response) async {
        Get.snackbar('Success', 'Profile picture updated');
        // refresh profile
        await fetchProfile();
        uploadingPhoto.value = false;
      },
      onFailure: (error, response) async {
        uploadingPhoto.value = false;
        await errorReport(response);
      },
    );
  }
}
