import 'package:enderase/controllers/favorites_controller.dart';
import 'package:enderase/models/category.dart';
import 'package:enderase/models/certifications.dart';
import 'package:enderase/models/provider.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:enderase/widgets/cards/provider/favorite_provider_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/assets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController favoritesController = Get.put(
      FavoritesController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => favoritesController.refreshFavorites(),
          ),
        ],
      ),
      body: Obx(() {
        if (favoritesController.loadingProviders.value ==
            ApiCallStatus.loading) {
          return ListView.builder(
            itemCount: 15,
            itemBuilder: (context, index) {
              return FavoriteProviderCard(
                provider: Provider(
                  id: 0,
                  firstName: 'firstName',
                  middleName: 'middleName',
                  lastName: 'lastName',
                  profilePicture: 'profilePicture',
                  cityEn: 'city',
                  subcityEn: 'subcity',
                  cityAm: 'city',
                  subCityAm: 'city',
                  woreda: 'woreda',
                  rating: 3,
                  categories: [
                    Category(
                      categoryNameEn: 'categoryName',
                      categoryNameAm: 'categoryNameAm',
                    ),
                  ],
                  certifications: Certifications.certifications,
                ),
                isShimmer: true,
                onRemove: () {},
              );
            },
          );
        }

        if (favoritesController.providers.isEmpty) {
          return Center(
            child: ErrorCard(
              errorData: ErrorData(
                title: 'no_favorites_found'.tr,
                buttonText: 'refresh'.tr,
                body: 'no_favorites_description'.tr,
                image: Assets.emptyCart,
              ),
              refresh: () => favoritesController.refreshFavorites(),
            ),
          );
        }

        return ListView.builder(
          controller: favoritesController.scrollController,
          itemCount:
              favoritesController.providers.length +
              (favoritesController.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == favoritesController.providers.length) {
              // Loading indicator at bottom for pagination
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final provider = favoritesController.providers[index];
            final isRemoving =
                favoritesController.removingProvider[provider.id] ?? false;

            return FavoriteProviderCard(
              provider: provider,
              isShimmer: false,
              isRemoving: isRemoving,
              onRemove: () =>
                  favoritesController.removeFromFavorites(provider.id!),
            );
          },
        );
      }),
    );
  }

  // void _showRemoveConfirmation(
  //   BuildContext context,
  //   Provider provider,
  //   FavoritesController controller,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('remove_from_favorites'.tr),
  //         content: Text(
  //           'remove_from_favorites_confirmation'.trParams({
  //             'name':
  //                 '${provider.firstName}${provider.middleName} ${provider.lastName}',
  //           }),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('cancel'.tr),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               controller.removeFromFavorites(provider.id!);
  //             },
  //             child: Text('remove'.tr, style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
