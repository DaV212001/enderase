import 'package:enderase/models/provider.dart';
import 'package:enderase/setup_files/templates/loaded_widgets_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/assets.dart';
import '../../../../controllers/provider_controller.dart';
import '../../../../setup_files/error_card.dart';
import '../../../../setup_files/error_data.dart';
import '../../../../widgets/cards/provider/top_rated_provider_card.dart';

class TopRatedProvidersList extends StatelessWidget {
  TopRatedProvidersList({super.key});

  final ProviderController controller = Get.find<ProviderController>(
    tag: ProviderController.tag,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.3,
      child: Obx(
        () => LoadedListWidget(
          apiCallStatus: controller.loadingTopRatedProviders.value,
          errorData: controller.errorTopRatedProviders.value,
          scrollToRefresh: false,
          loadingChild: SizedBox(
            height: MediaQuery.of(context).size.width * 0.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Provider.providers.length,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final provider = Provider.providers[index];
                final listOfCategories = (provider.categories ?? [])
                    .map((c) => c.categoryName)
                    .where((name) => name.isNotEmpty)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TopRatedProviderCard(
                    imageUrl: provider.profilePicture ?? '',
                    isShimmer: true,
                    name: '${provider.firstName} ${provider.middleName}',
                    location: '${provider.subcity}, ${provider.city}',
                    rating: provider.rating ?? 0,
                    listOfCategories: listOfCategories,
                    id: 0,
                  ),
                );
              },
            ),
          ),
          list: controller.topRatedProviders,
          onEmpty: Center(
            child: ErrorCard(
              errorData: ErrorData(
                title: 'no_providers_found'.tr,
                buttonText: 'refresh'.tr,
                body: '',
                image: Assets.emptyCart,
              ),
              refresh: () => controller.fetchProviders(refresh: true),
            ),
          ),
          onReload: () => controller.fetchTopRatedProviders(),
          child: SizedBox(
            height: MediaQuery.of(context).size.width * 0.27,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.topRatedProviders.length,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final provider = controller.topRatedProviders[index];
                final listOfCategories = (provider.categories ?? [])
                    .map((c) => c.categoryName)
                    .where((name) => name.isNotEmpty)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TopRatedProviderCard(
                    imageUrl: provider.profilePicture ?? '',
                    isShimmer: false,
                    name: '${provider.firstName}${provider.middleName}',
                    location: '${provider.subcity}, ${provider.city}',
                    rating: provider.rating ?? 0,
                    listOfCategories: listOfCategories,
                    id: provider.id ?? 0,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
