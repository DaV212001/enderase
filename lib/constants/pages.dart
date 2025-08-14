// import 'package:trip_cs_passenger/screens/main_layout_screen.dart';
// import 'package:trip_cs_passenger/utils/initial_navigation_middleware.dart';
//
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/signup_screen.dart';
// import '../screens/history/trip_history_detail_screen.dart';
// import '../screens/history/trip_history_screen.dart';
// import '../screens/main/home_screen.dart';
// import '../screens/main/route_detail_screen.dart';
// import '../screens/settings/app_info/about_us_screen.dart';
// import '../screens/settings/app_info/contact_us_screen.dart';
// import '../screens/settings/app_info/privacy_policy_screen.dart';
// import '../screens/settings/app_info/terms_and_conditions_screen.dart';
// import '../screens/settings/password/change_password_screen.dart';
// import '../screens/settings/password/forgot_password_screen.dart';
// import '../screens/settings/profile/profile_screen.dart';
// import '../screens/settings/settings_screen.dart';

import 'package:enderase/screen/main/home/layout/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../config/storage_config.dart';
import '../screen/auth/signin_screen.dart';
import '../screen/auth/signup_screen.dart';
import '../screen/main/main_layout_screen.dart';

class AppRoutes {
  static String get profileRoute => '/profile';
  static String get forgotPasswordRoute => '/forgot-password';
  static String get changePasswordRoute => '/change-password';
  static String get termsAndConditionsRoute => '/terms-and-conditions';
  static String get privacyPolicyRoute => '/privacy-policy';
  static String get contactUsRoute => '/contact-us';
  static String get aboutUsRoute => '/about-us';
  static String get settingsRoute => '/settings';
  static String get providerDetailRoute => '/route-detail';
  static String get searchRoute => '/search-screen';
  static String get homeRoute => '/main-screen';
  static String get favoritesRoute => '/favorites';
  static String get historyRoute => '/trip-history';
  static String get historyDetailRoute => '/trip-history-detail';
  static String get signupRoute => '/signup';
  static String get loginRoute => '/login';
  static String get mainLayoutRoute => '/main';
}

class Pages {
  static final List<GetPage> pages = [
    // GetPage(
    //   name: AppRoutes.profileRoute,
    //   page: () => const ProfileScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.forgotPasswordRoute,
    //   page: () => const ForgotPasswordScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.changePasswordRoute,
    //   page: () => const ChangePasswordScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.termsAndConditionsRoute,
    //   page: () => const TermsAndConditionsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.privacyPolicyRoute,
    //   page: () => const PrivacyPolicyScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.contactUsRoute,
    //   page: () => const ContactUsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.aboutUsRoute,
    //   page: () => const AboutUsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.settingsRoute,
    //   page: () => SettingsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.routeDetailRoute,
    //   page: () => RouteDetailScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.homeRoute,
    //   page: () => const HomeScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.tripHistoryRoute,
    //   page: () => const TripHistoryScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.tripHistoryDetailRoute,
    //   page: () => const TripHistoryDetailScreen(),
    // ),
    GetPage(
      name: AppRoutes.searchRoute,
      page: () => ProviderSearchFilterScreen(),
    ),
    GetPage(name: AppRoutes.signupRoute, page: () => const SignUpScreen()),
    GetPage(name: AppRoutes.loginRoute, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.mainLayoutRoute,
      page: () => MainLayoutScreen(),
      middlewares: [InitialNavigationMiddleware()],
    ),
  ];
}

class InitialNavigationMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool isAuthenticated = ConfigPreference.isUserLoggedIn();
    if (!isAuthenticated) {
      return RouteSettings(name: AppRoutes.loginRoute);
    }
    return null; // Allow the navigation
  }
}
