import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/constants/constants.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../constants/pages.dart';
import '../../../controllers/theme_mode_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../setup_files/error_logger.dart';
import '../../../setup_files/profile_list_card.dart';
import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../../../widgets/language_change_selector.dart';
import '../../../widgets/logout_confirmation_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> routesList = [
    {
      'name': 'edit_profile',
      'icon': Ionicons.person_circle,
      'onTap': () => Get.toNamed(AppRoutes.profileRoute),
      'isFirstTile': true,
      'isLastTile': false,
    },
    // {
    //   'name': 'my_wallet'.tr,
    //   'icon': EneftyIcons.wallet_2_bold,
    //   'onTap': () {},
    //   'isFirstTile': true,
    //   'isLastTile': true,
    // },
    {
      'name': 'help_support',
      'icon': Ionicons.help_circle,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'name': 'about_us',
      'icon': EneftyIcons.info_circle_bold,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'name': 'terms_conditions',
      'icon': Ionicons.document_text,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'name': 'privacy_policy',
      'icon': Ionicons.lock_closed,
      'onTap': () {},
      'isFirstTile': false,
      'isLastTile': false,
    },
    {
      'icon': Ionicons.send,
      'name': 'Report a bug',
      'isFirstTile': false,
      'isLastTile': true,
      'onTap': () async {
        ErrorLogger.showErrorReportDialog();
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: ThemeModeController.isLightTheme.value
                    ? AppConstants.primaryColor
                    : Theme.of(context).cardColor,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LanguageSelectorButton(onChange: () {}),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppConstants.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AnimatedToggleSwitch<bool>.dual(
                              current: ThemeModeController.isLightTheme.value,
                              first: false,
                              second: true,
                              borderWidth: 0.0,
                              height: 40,
                              onChanged: (val) {
                                ThemeModeController.toggleThemeMode(); // Toggle theme
                              },
                              style: ToggleStyle(
                                indicatorColor:
                                    ThemeModeController.isLightTheme.value
                                    ? AppConstants.primaryColor
                                    : null,
                                // backgroundGradient: LinearGradient(colors: [
                                //   ThemeModeController.isLightTheme.value
                                //       ? Colors.white
                                //       : AppConstants.primaryColor,
                                //   ThemeModeController.isLightTheme.value
                                //       ? Colors.grey
                                //       : Colors.black
                                // ]),
                                indicatorBorder: Border.all(
                                  color: ThemeModeController.isLightTheme.value
                                      ? Colors.white
                                      : AppConstants.primaryColor,
                                ),
                              ),
                              iconBuilder: (value) => value
                                  ? const Icon(
                                      Icons.light_mode,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.dark_mode,
                                      color: Colors.white,
                                    ),
                              textBuilder: (value) => value
                                  ? Center(child: Text('light'.tr))
                                  : Center(child: Text('dark'.tr)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              cachedNetworkImageWrapper(
                                imageUrl:
                                    UserController.user.value.profilePicture ??
                                    '',
                                height: MediaQuery.of(context).size.width * 0.2,
                                width: MediaQuery.of(context).size.width * 0.2,
                                imageBuilder: (context, imageProvider) =>
                                    CircularImageHolder(
                                      image: Image.network(
                                        UserController
                                                .user
                                                .value
                                                .profilePicture ??
                                            '',
                                        height:
                                            MediaQuery.of(context).size.width *
                                            0.2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.2,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                placeholderBuilder: (context, string) {
                                  return Icon(
                                    EneftyIcons.profile_circle_bold,
                                    color:
                                        !ThemeModeController.isLightTheme.value
                                        ? AppConstants.primaryColor
                                        : Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width * 0.2,
                                  );
                                },
                                errorWidgetBuilder: (context, path, obj) {
                                  return Icon(
                                    EneftyIcons.profile_circle_bold,
                                    color:
                                        !ThemeModeController.isLightTheme.value
                                        ? AppConstants.primaryColor
                                        : Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width * 0.2,
                                  );
                                },
                              ),
                              // Icon(
                              //   EneftyIcons.profile_circle_bold,
                              //   color: !ThemeModeController.isLightTheme.value
                              //       ? AppConstants.primaryColor
                              //       : Colors.white,
                              //   size: MediaQuery.of(context).size.width * 0.2,
                              // ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                              0.48) -
                                          16,
                                      child: AutoSizeText(
                                        (UserController.user.value.firstName ??
                                                '') +
                                            (' ') +
                                            (UserController
                                                    .user
                                                    .value
                                                    .middleName ??
                                                ''),
                                        maxLines: 1,
                                        minFontSize: 9,
                                        maxFontSize: 16,
                                        stepGranularity: 0.5,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Obx(() => SizedBox(
                                  //       width:
                                  //           (MediaQuery.of(context).size.width *
                                  //                   0.48) -
                                  //               16,
                                  //       child: AutoSizeText(
                                  //         '+${UserController.user.value.phone ?? ''}',
                                  //         maxLines: 1,
                                  //         minFontSize: 5,
                                  //         maxFontSize: 12,
                                  //         stepGranularity: 0.5,
                                  //         style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontSize: 12.sp),
                                  //       ),
                                  //     )),
                                  Obx(
                                    () => Text(
                                      (UserController.user.value.email ?? '')
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ...routesList.map(
                    (e) => Obx(() {
                      ThemeModeController.languageCode.value;
                      return ProfileListCard(
                        icon: e['icon'],
                        name: (e['name'] as String).tr,
                        onTap: e['onTap'],
                        isFirstTile: e['isFirstTile'],
                        isLastTile: e['isLastTile'],
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LogoutConfirmationDialog(),
                    );
                  },
                  child: Text(
                    'logout'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
