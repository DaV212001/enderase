import 'package:enderase/constants/pages.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:enderase/setup_files/error_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/assets.dart';
import '../../../../controllers/provider_controller.dart';
import '../../../../models/provider.dart';
import '../../../../setup_files/templates/loaded_widgets_template.dart';
import '../../../../widgets/cards/provider/professional_provider_card.dart';

class ProfessionalProvidersGrid extends StatelessWidget {
  ProfessionalProvidersGrid({super.key});

  final ProviderController controller = Get.find<ProviderController>(
    tag: ProviderController.tag,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //Empty state handled outside LoadedWidget
      if (controller.loadingProfessionalProviders.value ==
              ApiCallStatus.success &&
          controller.professionalProviders.isEmpty) {
        return Center(
          child: ErrorCard(
            errorData: ErrorData(
              title: 'no_providers_found'.tr,
              body: ''.tr,
              buttonText: 'refresh'.tr,
              image: Assets.emptyCart,
            ),
            refresh: () => controller.fetchProviders(refresh: true),
          ),
        );
      }

      return LoadedWidget(
        apiCallStatus: controller.loadingProfessionalProviders.value,
        errorData: controller.errorProfessionalProviders.value,
        onReload: () => controller.fetchProfessionalProviders(),
        loadingChild: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: (Provider.providers.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 3;
              final end = (start + 3 <= Provider.providers.length)
                  ? start + 3
                  : Provider.providers.length;
              final pageCards = Provider.providers.sublist(start, end);

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: pageCards
                    .map(
                      (provider) => ProfessionalProviderCard(
                        isShimmer: true,
                        imageUrl: provider.profilePicture ?? '',
                        name: '${provider.firstName} ${provider.middleName}',
                        location:
                            '${provider.subcity}, ${provider.city}, Woreda ${provider.woreda}',
                        rating: (provider.rating ?? 0).toDouble(),
                        certificateNumber:
                            (provider.certifications ?? []).length,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: (controller.professionalProviders.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 3;
              final end = (start + 3 <= controller.professionalProviders.length)
                  ? start + 3
                  : controller.professionalProviders.length;
              final pageCards = controller.professionalProviders.sublist(
                start,
                end,
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: pageCards
                    .map(
                      (provider) => InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.providerDetailRoute,
                            arguments: provider.id,
                          );
                        },
                        child: ProfessionalProviderCard(
                          isShimmer: false,
                          imageUrl: provider.profilePicture ?? '',
                          name: '${provider.firstName}${provider.middleName}',
                          location:
                              '${provider.subcity}, ${provider.city}, ${'woreda'.tr} ${provider.woreda}',
                          rating: (provider.rating ?? 0).toDouble(),
                          certificateNumber:
                              (provider.certifications ?? []).length,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      );
    });
  }
}
