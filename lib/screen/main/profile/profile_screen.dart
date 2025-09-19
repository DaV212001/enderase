import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../controllers/client_profile_controller.dart';
import '../../../widgets/input_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientProfileController());
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(title: Text('edit_profile'.tr)),
      body: Obx(
        () => controller.loading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Obx(() {
                              final fileImage = controller.pickedImage.value;
                              if (fileImage != null) {
                                return CircleAvatar(
                                  radius: 48,
                                  backgroundImage: Image.file(fileImage).image,
                                );
                              }
                              final url =
                                  controller.profile.value.profilePicture;
                              if (url != null && url.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 48,
                                  backgroundImage: CachedNetworkImageProvider(
                                    url,
                                  ),
                                );
                              }
                              return const CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.transparent,
                                child: Icon(Ionicons.person_circle, size: 64),
                              );
                            }),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Ionicons.camera,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await controller.pickProfilePicture();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.pickedImage.value == null ||
                                  controller.uploadingPhoto.value
                              ? null
                              : controller.uploadProfilePicture,
                          icon: const Icon(
                            Ionicons.cloud_upload,
                            color: Colors.white,
                          ),
                          label: controller.uploadingPhoto.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "pick_profile_picture".tr,
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InputFieldWidget(
                        textEditingController: controller.firstNameController,
                        focusNode: FocusNode(),
                        validator: (val) {
                          // if (val == null || val.isEmpty) {
                          //   return "name_required".tr;
                          // }
                          if (val != null && val.split(' ').length != 3) {
                            return "must_include_up_to_grand_father".tr;
                          } else if (val != null && val.split(' ')[2].isEmpty) {
                            return "must_include_up_to_grand_father".tr;
                          }
                          return null;
                        },
                        obscureText: false,
                        passwordInput: false,
                        label: 'full_name'.tr,
                      ),
                      // InputFieldWidget(
                      //   textEditingController: controller.middleNameController,
                      //   focusNode: FocusNode(),
                      //   obscureText: false,
                      //   passwordInput: false,
                      //   validator: (v) =>
                      //       v == null || v.trim().isEmpty ? 'Required' : null,
                      //   label: 'Middle name',
                      // ),
                      // InputFieldWidget(
                      //   textEditingController: controller.lastNameController,
                      //   focusNode: FocusNode(),
                      //   obscureText: false,
                      //   passwordInput: false,
                      //   validator: (v) =>
                      //       v == null || v.trim().isEmpty ? 'Required' : null,
                      //   label: 'Last name',
                      // ),
                      InputFieldWidget(
                        textEditingController: controller.fanNumberController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        validator: (v) => null,
                        label: 'fan_number'.tr,
                      ),
                      InputFieldWidget(
                        textEditingController:
                            controller.primaryPhoneController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        textInputType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'phone_required'.tr;
                          }
                          if (!RegExp(
                            r'^(\+251|0)?[79]\d{8}$',
                          ).hasMatch(v.trim())) {
                            return 'invalid_phone'.tr;
                          }
                          return null;
                        },
                        label: 'phone_number'.tr,
                      ),
                      InputFieldWidget(
                        textEditingController:
                            controller.secondaryPhoneController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        textInputType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return null; // optional
                          }
                          if (!RegExp(
                            r'^(\+251|0)?[79]\d{8}$',
                          ).hasMatch(v.trim())) {
                            return 'invalid_phone'.tr;
                          }
                          return null;
                        },
                        label: 'secondary_phone'.tr,
                      ),
                      InputFieldWidget(
                        textEditingController:
                            controller.landlinePhoneController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        textInputType: TextInputType.phone,
                        validator: (v) => null,
                        label: 'landline_phone'.tr,
                      ),
                      _CityDropdown(controller: controller),
                      _SubCityDropdown(controller: controller),
                      InputFieldWidget(
                        textEditingController: controller.woredaController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        textInputType: TextInputType.number,
                        validator: (v) => null,
                        label: 'woreda'.tr,
                      ),
                      InputFieldWidget(
                        textEditingController: controller.houseNumberController,
                        focusNode: FocusNode(),
                        obscureText: false,
                        passwordInput: false,
                        validator: (v) => null,
                        label: 'house_number'.tr,
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.saving.value
                              ? null
                              : controller.updateProfile,
                          child: controller.saving.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'submit'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        'change_pass'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: controller.passwordFormKey,
                        child: Column(
                          children: [
                            InputFieldWidget(
                              textEditingController:
                                  controller.currentPasswordController,
                              focusNode: FocusNode(),
                              obscureText: true,
                              passwordInput: true,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Required'.tr
                                  : v.length < 8
                                  ? 'password_requirement'.tr
                                  : null,
                              label: 'current_password'.tr,
                            ),
                            InputFieldWidget(
                              textEditingController:
                                  controller.newPasswordController,
                              focusNode: FocusNode(),
                              obscureText: true,
                              passwordInput: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'required'.tr;
                                }
                                if (v.length < 8) {
                                  return 'password_requirement'.tr;
                                }
                                return null;
                              },
                              label: 'new_password'.tr,
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => SwitchListTile(
                          value: controller.logoutOthers.value,
                          onChanged: (v) => controller.logoutOthers.value = v,
                          title: Text('logout_from_other_devices'.tr),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.changingPassword.value
                              ? null
                              : controller.changePassword,
                          child: controller.changingPassword.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'change_pass'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.controller});
  final ClientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'city'.tr,
              labelStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                value: controller.selectedCityId.value,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Select city'),
                  ),
                  ...controller.cities.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (val) {
                  controller.selectedCityId.value = val;
                  controller.selectedSubCityId.value = null;
                  controller.fetchSubCities();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubCityDropdown extends StatelessWidget {
  const _SubCityDropdown({required this.controller});
  final ClientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'sub_city'.tr,
              labelStyle: const TextStyle(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                value: controller.selectedSubCityId.value,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Select subcity'),
                  ),
                  ...controller.subCities.map(
                    (s) => DropdownMenuItem<int?>(
                      value: s.id,
                      child: Text(s.name ?? ''),
                    ),
                  ),
                ],
                onChanged: (val) {
                  controller.selectedSubCityId.value = val;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
