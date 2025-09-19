import 'package:enderase/config/storage_config.dart';
import 'package:enderase/constants/pages.dart';
import 'package:enderase/setup_files/templates/dio_template.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LogoutService {
  static Future<bool> logout({required bool clearAll}) async {
    try {
      Logger().d('Logging out with clearAll: $clearAll');

      await DioService.dioPost(
        path: '/api/v1/client/auth/signout',
        data: {'clear_all': clearAll},
        onSuccess: (response) {
          // Clear local storage
          ConfigPreference.logOut();

          // Navigate to login screen
          Get.offAllNamed(AppRoutes.loginRoute);

          // Show success message
          Get.snackbar(
            'logout_successful'.tr,
            '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.primaryColor,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        },
        onFailure: (error, response) {
          // Even if API call fails, clear local data and logout
          ConfigPreference.logOut();
          Get.offAllNamed(AppRoutes.loginRoute);

          // Get.snackbar(
          //   'error'.tr,
          //   'logout_failed'.tr,
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: Get.theme.colorScheme.error,
          //   colorText: Get.theme.colorScheme.onError,
          // );
        },
      );

      return true;
    } catch (e) {
      Logger().e('Logout exception: $e');

      // Even if there's an exception, clear local data and logout
      ConfigPreference.logOut();
      Get.offAllNamed(AppRoutes.loginRoute);

      // Get.snackbar(
      //   'error'.tr,
      //   'logout_failed'.tr,
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Get.theme.colorScheme.error,
      //   colorText: Get.theme.colorScheme.onError,
      // );

      return false;
    }
  }
}
