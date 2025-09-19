import 'package:enderase/constants/constants.dart';
import 'package:enderase/controllers/provider_controller.dart';
import 'package:enderase/controllers/user_controller.dart';
import 'package:enderase/screen/main/home/layout/provider_grid.dart';
import 'package:enderase/setup_files/wrappers/cached_image_widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../search/search_screen.dart';
import 'layout/category_grid.dart';
import 'layout/professional_providers_grid.dart';
import 'layout/top_rated_provider_list.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final ProviderController providerController = Get.put(
    ProviderController(),
    tag: ProviderController.tag,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        // surfaceTintColor: Colors.white,
        // shadowColor: Colors.white,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('MATIF'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: cachedNetworkImageWrapper(
              imageUrl: UserController.user.value.profilePicture ?? "",
              imageBuilder: (context, imageProvider) => CircularImageHolder(
                image: Image.network(
                  UserController.user.value.profilePicture ?? "",
                  height: 20,
                  width: 20,
                ),
              ),
              placeholderBuilder: (context, path) => Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryColor,
                ),
              ),
              errorWidgetBuilder: (context, path, obj) => Icon(
                Icons.person_2_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Hero(
                    tag: 'providerSearchHero',
                    child: Material(
                      child: GestureDetector(
                        onTap: () => Get.to(
                          () => ProviderSearchFilterScreen(),
                          transition: Transition.cupertino,
                        ),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            // boxShadow: kCardShadow(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'search'.tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: CategoryGrid(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        left: 4.0,
                        bottom: 15,
                      ),
                      child: Text(
                        'top_rated'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
                TopRatedProvidersList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 17.0,
                        left: 4.0,
                        bottom: 15,
                      ),
                      child: Text(
                        'professional'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
                ProfessionalProvidersGrid(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 17.0,
                    left: 4.0,
                    bottom: 15,
                  ),
                  child: Text(
                    'nearby'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: ProviderGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
