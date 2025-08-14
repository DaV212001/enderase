import 'package:enderase/constants/pages.dart';
import 'package:enderase/controllers/user_controller.dart';
import 'package:enderase/screen/main/favorites/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../constants/constants.dart';
import '../screen/main/history/history_screen.dart';
import '../screen/main/home/home_screen.dart';
import '../screen/main/profile/profile_screen.dart';

class MainLayoutController extends GetxController {
  static String tag = 'mainLayout';
  late PersistentTabController bottomTabController;
  @override
  void onInit() {
    UserController.getLoggedInUser();
    bottomTabController = PersistentTabController();
    super.onInit();
  }

  List<PersistentTabConfig> tabs = [
    PersistentTabConfig(
      screen: HomeScreen(),
      item: _buildNavItem(
        icon: Icons.home,
        title: 'Home',
        route: AppRoutes.homeRoute,
      ),
    ),
    PersistentTabConfig(
      screen: FavoritesScreen(),
      item: _buildNavItem(
        icon: Icons.favorite,
        title: 'Favorites',
        route: AppRoutes.favoritesRoute,
      ),
    ),
    PersistentTabConfig(
      screen: HistoryScreen(),
      item: _buildNavItem(
        icon: Icons.history,
        title: 'History',
        route: AppRoutes.historyRoute,
      ),
    ),
    PersistentTabConfig(
      screen: ProfileScreen(),
      item: _buildNavItem(
        icon: Icons.person,
        title: 'Profile',
        route: AppRoutes.profileRoute,
      ),
    ),
  ];
  static ItemConfig _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final theme = Theme.of(Get.context!);
    return ItemConfig(
      icon: Icon(icon, color: AppConstants.primaryColor),
      inactiveIcon: Icon(
        icon,
        color: theme.textTheme.bodyLarge!.color?.withValues(alpha: 0.5),
      ),
      title: title,
      textStyle: const TextStyle(fontSize: 10),
      iconSize: 22,
      activeForegroundColor: AppConstants.primaryColor,
      inactiveForegroundColor: theme.textTheme.bodyLarge!.color!.withValues(
        alpha: 0.5,
      ),
      // routeAndNavigatorSettings: RouteAndNavigatorSettings(initialRoute: route),
    );
  }
}
