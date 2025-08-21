import 'package:enderase/constants/assets.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/provider_controller.dart';
import '../../../../setup_files/error_data.dart';
import '../../../../setup_files/templates/loaded_widgets_template.dart';
import '../../../../widgets/cards/provider/provider_card.dart';

class ProviderGrid extends StatelessWidget {
  final ProviderController controller = Get.find<ProviderController>(
    tag: ProviderController.tag,
  );

  ProviderGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 🟡 Empty case handled outside LoadedWidget
      if (controller.loadingProviders.value == ApiCallStatus.success &&
          controller.providers.isEmpty) {
        return Center(
          child: ErrorCard(
            errorData: ErrorData(
              title: 'no_providers_found'.tr,
              buttonText: 'refresh'.tr,
              body: '',
              image: Assets.emptyCart,
            ),
            refresh: () => controller.fetchProviders(refresh: true),
          ),
        );
      }

      return LoadedWidget(
        apiCallStatus: controller.loadingProviders.value,
        errorData: controller.errorProviderFetching.value,
        onReload: () => controller.fetchProviders(refresh: true),
        loadingChild: GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.65,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return ProviderCard(
              image: "",
              name: "Loading Name",
              location: "Loading Location",
              rating: 0,
              categoriesList: ["Loading"],
              isShimmer: true,
            );
          },
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: controller.providers.length,
          itemBuilder: (context, index) {
            final provider = controller.providers[index];
            return ProviderCard(
              image: provider.profilePicture ?? "",
              name: '${provider.firstName}${provider.middleName}',
              location:
                  '${provider.subcity}, ${provider.city}, ${'woreda'.tr} ${provider.woreda}',
              rating: (provider.rating ?? 0).toDouble(),
              categoriesList: (provider.categories ?? [])
                  .map((c) => c.categoryName ?? "")
                  .where((name) => name.isNotEmpty)
                  .toList(),
              isShimmer: false,
            );
          },
        ),
      );
    });
  }
}
