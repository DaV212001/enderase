import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../controllers/main_layout_controller.dart';

class MainLayoutScreen extends StatelessWidget {
  MainLayoutScreen({super.key});
  final mainLayoutController = Get.put(
    MainLayoutController(),
    tag: MainLayoutController.tag,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: PersistentTabView(
        controller: mainLayoutController.bottomTabController,
        tabs: mainLayoutController.tabs,
        navBarBuilder: (navBarConfig) => Style8BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(
            padding: EdgeInsets.all(16),
            color: theme.scaffoldBackgroundColor,
          ),
        ),
        // navBarHeight: 60,
        // confineInSafeArea: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
      ),
    );
  }
}
