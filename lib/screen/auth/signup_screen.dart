import 'package:enderase/setup_files/animated_widgets/loading_animation_dropdown.dart';
import 'package:enderase/setup_files/templates/loaded_widgets_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../widgets/footer.dart';
import '../../widgets/input_field.dart';
import '../../widgets/main_button.dart';

String stepStringFromIndex(int index) {
  switch (index) {
    case 0:
      return 'step_personal_info'.tr;
    case 1:
      return 'step_contact_details'.tr;
    case 2:
      return 'step_address_info'.tr;
    case 3:
      return 'step_profile_picture'.tr;
    default:
      return '';
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signUpController = Get.put(UserController());
    final radius = 50.0;

    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2562EB), Color(0xFF9334EA)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(0.87, -1),
                  end: AlignmentDirectional(-0.87, 1),
                ),
              ),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return Row(
                              children: [
                                Obx(
                                  () => Container(
                                    width: radius,
                                    height: radius,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          signUpController.tabIndex.value ==
                                              index
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (index != 3)
                                  Container(
                                    width: 30,
                                    height: 3,
                                    color: Colors.white,
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                      Obx(
                        () => Text(
                          stepStringFromIndex(signUpController.tabIndex.value),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: TabBarView(
                                controller:
                                    signUpController.tabController.value,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  buildStep1(signUpController),
                                  buildStep2(signUpController),
                                  buildStep3(signUpController),
                                  buildStep4(signUpController),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStep1(UserController signUpController) {
    return buildFormWrapper(
      signUpController,
      SingleChildScrollView(
        child: Column(
          children: [
            InputFieldWidget(
              textEditingController: signUpController.nameController,
              focusNode: signUpController.firstnameFocusNode,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "name_required".tr;
                }
                if (val.split(' ').length != 3) {
                  return "must_include_up_to_grand_father".tr;
                } else if (val.split(' ')[2].isEmpty) {
                  return "must_include_up_to_grand_father".tr;
                }
                return null;
              },
              obscureText: false,
              passwordInput: false,
              label: 'full_name'.tr,
            ),
            InputFieldWidget(
              textEditingController:
                  signUpController.emailAddressSignUpController,
              focusNode: signUpController.emailAddressSignUpFocusNode,
              validator: (val) {
                if (!val!.isEmail) {
                  return "valid_email".tr;
                }
                return null;
              },
              obscureText: false,
              passwordInput: false,
              label: 'email'.tr,
            ),
            InputFieldWidget(
              textEditingController: signUpController.passwordSignUpController,
              focusNode: signUpController.passwordSignUpFocusNode2,
              passwordInput: true,
              obscureText: false,
              label: 'password'.tr,
              validator: (val) {
                if (val!.length < 8) return "password_requirement".tr;
                return null;
              },
            ),
            InputFieldWidget(
              textEditingController: signUpController.fanNumberController,
              focusNode: FocusNode(),
              passwordInput: false,
              obscureText: false,
              label: 'FAN Number (Fayda ID)'.tr,
              validator: (val) {
                if (val!.length < 16) return "Fayda number is required".tr;
                return null;
              },
            ),
          ],
        ),
      ),
      signUpController.step1Key,
    );
  }

  Widget buildStep2(UserController signUpController) {
    return buildFormWrapper(
      signUpController,
      SingleChildScrollView(
        child: Column(
          children: [
            InputFieldWidget(
              textEditingController: signUpController.phoneController,
              focusNode: signUpController.phoneFocusNode,
              label: 'phone_number'.tr,
              obscureText: false,
              passwordInput: false,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'phone_required'.tr;
                }
                final regex = RegExp(r'^(\+251|0)?[79]\d{8}$');
                if (!regex.hasMatch(v)) {
                  return 'invalid_phone'.tr;
                }
                return null;
              },
            ),
            InputFieldWidget(
              textEditingController: signUpController.secondaryPhoneController,
              focusNode: signUpController.confirmPasswordSignUpFocusNode2,
              label: 'secondary_phone'.tr,
              obscureText: false,
              passwordInput: false,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return null;
                }
                final regex = RegExp(r'^(\+251|0)?[79]\d{8}$');
                if (!regex.hasMatch(v ?? '')) {
                  return 'invalid_phone'.tr;
                }
                return null;
              },
            ),
            InputFieldWidget(
              textEditingController: signUpController.landlinePhoneController,
              focusNode: signUpController.landlinePhoneFocusNode2,
              label: 'landline_phone'.tr,
              obscureText: false,
              passwordInput: false,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return null;
                }
                final regex = RegExp(r'^(\+251|0)?\d{9}$');
                if (!regex.hasMatch(v ?? '')) {
                  return 'invalid_phone'.tr;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      signUpController.step2Key,
    );
  }

  Widget buildStep3(UserController signUpController) {
    return buildFormWrapper(
      signUpController,
      SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Obx(
                () => LoadedWidget(
                  apiCallStatus: signUpController.cityLoading.value,
                  loadingChild: LoadingAnimatedDropdown(
                    items: [DropdownMenuItem(child: Text('city'))],
                    onChanged: (v) {},
                  ),
                  errorChild: Text('Failed. Tap to retry'),
                  onReload: signUpController.fetchCities,
                  child: DropdownButtonFormField<String>(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Lexend',
                    ),
                    value: signUpController.selectedCityId.value == 0
                        ? null
                        : signUpController.selectedCityId.value.toString(),
                    items: signUpController.cities
                        .map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city.id.toString(),
                            child: Text(city.name ?? ''),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      signUpController.selectedCityId.value = int.parse(
                        value ?? '0',
                      );
                      signUpController.fetchSubCities();
                    },
                    decoration: InputDecoration(
                      labelText: 'city'.tr,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
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
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F4F8),
                      errorMaxLines: 2,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Obx(
                () => LoadedWidget(
                  apiCallStatus: signUpController.subCityLoading.value,
                  loadingChild: LoadingAnimatedDropdown(
                    items: [DropdownMenuItem(child: Text('sub city'))],
                    onChanged: (v) {},
                  ),
                  errorChild: Text('Failed. Tap to retry'),
                  onReload: signUpController.fetchSubCities,
                  child: DropdownButtonFormField<String>(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Lexend',
                    ),
                    value: signUpController.selectedSubCityId.value == 0
                        ? null
                        : signUpController.selectedSubCityId.value.toString(),
                    items: signUpController.subCities
                        .map<DropdownMenuItem<String>>((subcity) {
                          return DropdownMenuItem<String>(
                            value: subcity.id.toString(),
                            child: Text(subcity.name ?? ''),
                          );
                        })
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'sub_city'.tr,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
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
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F4F8),
                      errorMaxLines: 2,
                    ),
                    onChanged: (value) {
                      signUpController.selectedSubCityId.value = int.parse(
                        value ?? '0',
                      );
                    },
                  ),
                ),
              ),
            ),
            InputFieldWidget(
              textEditingController: signUpController.woredaController,
              focusNode: signUpController.woredaFocusNode2,
              label: 'woreda'.tr,
              obscureText: false,
              passwordInput: false,
              validator: (v) {
                if (v!.isEmpty) {
                  return 'woreda_required'.tr;
                }
                return null;
              },
            ),
            InputFieldWidget(
              textEditingController: signUpController.houseNumberController,
              focusNode: signUpController.houseNumberFocusNode2,
              label: 'house_number'.tr,
              obscureText: false,
              passwordInput: false,
              validator: (v) {
                return null;
              },
            ),
          ],
        ),
      ),
      signUpController.step3Key,
    );
  }

  Widget buildStep4(UserController signUpController) {
    return buildFormWrapper(
      signUpController,
      SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () => Stack(
                clipBehavior: Clip.none,
                children: [
                  signUpController.profilePhotoFile.value == null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.file(
                            signUpController.profilePhotoFile.value!,
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    right: -15,
                    child: IconButton(
                      onPressed: signUpController.pickImage,
                      icon: Icon(
                        signUpController.profilePhotoFile.value == null
                            ? Icons.add_circle_rounded
                            : Icons.change_circle,
                        size: 30,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Text("Pick Profile Picture"),
            Obx(
              () => signUpController.signingUp.value
                  ? const CircularProgressIndicator()
                  : MainButton(
                      isLoading: signUpController.signingUp.value,
                      onPress: () => signUpController.signUp(),
                      text: 'create_account'.tr,
                    ),
            ),
          ],
        ),
      ),
      signUpController.step4Key,
    );
  }

  Widget buildFormWrapper(
    UserController signUpController,
    Widget child,
    GlobalKey<FormState> key,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 570),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x33000000),
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(key: key, child: child),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          signUpController.tabIndex.value > 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    signUpController.tabController.value
                                        .animateTo(
                                          signUpController.tabIndex.value - 1,
                                        );
                                    signUpController.tabIndex.value--;
                                  },
                                  child: const Text(
                                    "Previous",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : const SizedBox(),
                          signUpController.tabIndex.value < 3
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Validate current step before moving on
                                    if (signUpController
                                        .validateCurrentStep()) {
                                      signUpController.tabController.value
                                          .animateTo(
                                            signUpController.tabIndex.value + 1,
                                          );
                                      signUpController.tabIndex.value++;
                                    }
                                  },
                                  child: const Text(
                                    "Next",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  const Footer(isLogin: false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
