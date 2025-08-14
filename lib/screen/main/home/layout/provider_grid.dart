import 'package:enderase/constants/assets.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/provider_controller.dart';
import '../../../../setup_files/error_data.dart';
import '../../../../widgets/cards/provider/provider_card.dart';

class ProviderGrid extends StatelessWidget {
  final ProviderController controller = Get.put(ProviderController());

  ProviderGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Handle loading state
      if (controller.loadingProviders.value == ApiCallStatus.loading) {
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // same as your real layout
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.65,
          ),
          itemCount: 6, // number of shimmer placeholders to show
          itemBuilder: (context, index) {
            return ProviderCard(
              image: "", // empty for shimmer
              name: "Loading Name", // placeholder
              location: "Loading Location", // placeholder
              rating: 0,
              categoriesList: ["Loading"], // placeholder
              isShimmer: true,
            );
          },
        );
      }

      // Handle error
      if (controller.loadingProviders.value == ApiCallStatus.error) {
        return Center(
          child: ErrorCard(
            errorData: controller.errorProviderFetching.value,
            refresh: () => controller.fetchProviders(refresh: true),
          ),
        );
      }

      // Empty state
      if (controller.providers.isEmpty) {
        return Center(
          child: ErrorCard(
            errorData: ErrorData(
              title: 'no_providers_found'.tr,
              body: 'refresh'.tr,
              image: Assets.emptyCart,
            ),
            refresh: () => controller.fetchProviders(refresh: true),
          ),
        );
      }

      // Provider list in GridView
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 100) {
            controller.loadMoreProviders();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72, // Adjust height/width ratio
          ),
          itemCount: controller.providers.length,
          //+ (controller.hasMore ? 1 : 0), // add loading more indicator
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index < controller.providers.length) {
              final provider = controller.providers[index];
              return ProviderCard(
                image: provider.profilePicture ?? "",
                name: provider.firstName + provider.middleName,
                location: '${provider.subcity}, ${provider.city}',
                rating: provider.rating.toDouble(),
                categoriesList: provider.categories
                    .map((c) => c.categoryName ?? "")
                    .where((name) => name.isNotEmpty)
                    .toList(),
                isShimmer: false,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
    });
  }
}
