import 'package:enderase/widgets/language_change_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../setup_files/animated_widgets/loading_animation_button.dart';
import '../../setup_files/animations.dart';
import '../../widgets/footer.dart';
import '../../widgets/input_field.dart';
import '../../widgets/main_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  UserController logInController = Get.put(UserController());
  final animationsMap = {
    'containerOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 1.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: 0,
          end: 1,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(0, 140),
          end: const Offset(0, 0),
        ),
        ScaleEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        ),
        TiltEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(-0.349, 0),
          end: const Offset(0, 0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
  }

  bool agreedToTerms = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: 100,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B39EF), Color(0xFFEE8B60)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(0.87, -1),
                  end: AlignmentDirectional(-0.87, 1),
                ),
              ),
              alignment: const AlignmentDirectional(0, -1),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: LanguageSelectorButton(onChange: () {}),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        70,
                        0,
                        32,
                      ),
                      child: Container(
                        width: 284,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: const AlignmentDirectional(0, 0),
                        child: Text(
                          'login'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    buildBody(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 570),
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
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildForm(context),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: Obx(
                    () => logInController.loggingIn.value
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: LoadingAnimatedButton(
                              onTap: () {},
                              borderRadius: 25,
                              height: 50,
                              width: double.infinity,
                              child: Text(
                                'login'.tr,
                                style: const TextStyle(
                                  color: Color(0xFF4B39EF),
                                ),
                              ),
                            ),
                          )
                        : MainButton(
                            isLoading: logInController.loggingIn.value,
                            onPress: () => logInController.logIn(),
                            text: 'login'.tr,
                          ),
                  ),
                ),
                const Footer(isLogin: true),
              ],
            ),
          ),
        ),
      ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
    );
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: logInController.loginKey,
      child: Column(
        children: [
          // InputFieldWidget(
          //     textEditingController: signUpController.firstnameController,
          //     focusNode: signUpController.firstnameFocusNode,
          //     validator: (val) {
          //       if (val!.length < 2) {
          //         return "First name must be at least 2 characters.";
          //       }
          //       return null;
          //     },
          //     obscureText: false,
          //     passwordinput: false,
          //     label: 'First name'),
          // InputFieldWidget(
          //     textEditingController: signUpController.lastnameController,
          //     focusNode: signUpController.lastnameFocusNode,
          //     validator: (val) {
          //       if (val!.length < 2) {
          //         return "Last name must be at least 2 characters.";
          //       }
          //       return null;
          //     },
          //     obscureText: false,
          //     passwordinput: false,
          //     label: 'Last name'),
          InputFieldWidget(
            textEditingController: logInController.emailorPhoneSignInController,
            focusNode: logInController.emailAddressSignInFocusNode,
            validator: (val) {
              if (!val!.isEmail) {
                return "valid_email".tr;
              }
              return null;
            },
            obscureText: false,
            label: 'email_phone'.tr,
            passwordInput: false,
          ),
          InputFieldWidget(
            textEditingController: logInController.passwordSignInController,
            focusNode: logInController.passwordSignInFocusNode2,
            passwordInput: true,
            obscureText: false,
            label: 'password'.tr,
            validator: (val) {
              print("length ${val!.length}");
              if (val.length < 8) {
                return "password_requirement".tr;
              }
              return null;
            },
          ),
          // InputFieldWidget(
          //     textEditingController: signUpController.phoneController,
          //     focusNode: signUpController.phoneFocusNode,
          //     label: 'Phone number',
          //     validator: (val) {
          //       if (val!.length < 10) {
          //         return "Invalid Phone Number";
          //       }
          //       return null;
          //     },
          //     obscureText: false,
          //     passwordinput: false)
        ],
      ),
    );
  }
}
