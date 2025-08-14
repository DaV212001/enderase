import 'package:enderase/constants/constants.dart';
import 'package:enderase/controllers/user_controller.dart';
import 'package:enderase/screen/main/home/layout/provider_grid.dart';
import 'package:enderase/setup_files/wrappers/cached_image_widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'layout/category_grid.dart';
import 'layout/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enderase'),
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
                color: AppConstants.primaryColor,
              ),
              errorWidgetBuilder: (context, path, obj) =>
                  Icon(Icons.person_2_rounded),
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
                              children: const [
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Search providers...',
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: CategoryGrid(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                    left: 4.0,
                    bottom: 15,
                  ),
                  child: Text(
                    'Service Providers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ProviderGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
