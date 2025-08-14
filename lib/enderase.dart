import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/translation.dart';
import 'constants/pages.dart';
import 'controllers/theme_mode_controller.dart';

class Enderase extends StatelessWidget {
  const Enderase({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeModeController(context));
    // UserController.getLoggedInUser();
    return Obx(
      () => ScreenUtilInit(
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: ThemeModeController.getLocale(),
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppRoutes.mainLayoutRoute,
          theme: ThemeModeController.getThemeMode(),
          getPages: Pages.pages,
        ),
      ),
    );
  }
}
