import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/controllers/provider_detail_controller.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:enderase/setup_files/error_card.dart';
import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:enderase/widgets/animated_bookmark_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../controllers/theme_mode_controller.dart';
import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../../../widgets/cards/category/category_card_for_provider_detail.dart';
import '../../../widgets/cards/certificate/certificate_card.dart';
import '../../../widgets/rating/review_list.dart';
import 'layout/booking_form.dart';

class ProviderDetailScreen extends StatelessWidget {
  ProviderDetailScreen({super.key});

  final controller = Get.put(ProviderDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Get.to(
                () => BookingFlow(
                  categories: controller.provider.value.categories ?? [],
                  providerId: controller.providerId,
                ),
                arguments: controller.provider.value,
              ),
              child: Text(
                'book_provider'.tr,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.providerLoading.value == ApiCallStatus.error) {
          return Center(
            child: ErrorCard(
              errorData: controller.providerError.value,
              refresh: controller.fetchProvider,
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return ShimmerWrapper(
                  isEnabled:
                      controller.providerLoading.value == ApiCallStatus.loading,
                  child: buildProfileImage(context),
                );
              }),
              Container(
                color: Theme.of(context).cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProviderInfo(context),
                    buildLanguagesSpoken(),
                    buildWorkRadiusAndRate(context),

                    // Divider(thickness: 0.5),
                    Divider(thickness: 0.5),
                    if (controller.provider.value.categories != null &&
                        controller.provider.value.categories!.isNotEmpty)
                      buildOccupations(context),
                    if (controller.providerLoading.value !=
                            ApiCallStatus.loading &&
                        (controller.provider.value.certifications ?? [])
                            .isNotEmpty)
                      buildCertificates(context),
                    Divider(thickness: 0.5),
                    buildReviewsSection(context),
                  ],
                ),
              ),
              SizedBox(height: 75),
            ],
          ),
        );
      }),
    );
  }

  Widget buildCertificates(BuildContext context) {
    var certificationImage = 'image';
    var certificateName = 'CoC certification';
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
            child: Text('certifications'.tr, style: TextStyle(fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    controller.providerLoading.value == ApiCallStatus.loading
                    ? [
                        CertificateCard(
                          isShimmer: true,
                          certificationImage: certificationImage,
                          certificateName: certificateName,
                        ),
                        CertificateCard(
                          isShimmer: true,
                          certificationImage: certificationImage,
                          certificateName: certificateName,
                        ),
                      ]
                    : (controller.provider.value.certifications ?? [])
                          .map(
                            (cert) => CertificateCard(
                              certificationImage: cert.image ?? '',
                              certificateName: cert.name ?? 'Certification',
                              isShimmer: false,
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
            child: Text('reviews'.tr, style: TextStyle(fontSize: 13)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ReviewList(),
          ),
        ],
      ),
    );
  }

  Column buildOccupations(BuildContext context) {
    var imageUrl = 'imageUrl';
    var categoryName = 'Nurse';
    var certified = true;
    var pricePerHour = 353.45;
    var experienceLevel = 'Advanced';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
          child: Text('cccupations'.tr, style: TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Column(
            children: controller.providerLoading.value == ApiCallStatus.loading
                ? [
                    CategoryDetailCard(
                      isShimmer: true,
                      imageUrl: imageUrl,
                      categoryName: categoryName,
                      certified: certified,
                      pricePerHour: pricePerHour,
                      experienceLevel: experienceLevel,
                    ),
                    CategoryDetailCard(
                      isShimmer: true,
                      imageUrl: imageUrl,
                      categoryName: categoryName,
                      certified: certified,
                      pricePerHour: pricePerHour,
                      experienceLevel: experienceLevel,
                    ),
                    CategoryDetailCard(
                      isShimmer: true,
                      imageUrl: imageUrl,
                      categoryName: categoryName,
                      certified: certified,
                      pricePerHour: pricePerHour,
                      experienceLevel: experienceLevel,
                    ),
                  ]
                : (controller.provider.value.categories ?? [])
                      .map(
                        (cat) => CategoryDetailCard(
                          imageUrl: cat.image ?? '',
                          categoryName: cat.categoryName,
                          certified: cat.certified ?? false,
                          pricePerHour: double.parse(cat.hourlyRate ?? '0.0'),
                          experienceLevel:
                              (cat.skillLevel ?? '').capitalizeFirst ?? '',
                          isShimmer: false,
                        ),
                      )
                      .toList(),
          ),
        ),
      ],
    );
  }

  Widget buildLanguagesSpoken() {
    return ShimmerWrapper(
      isEnabled: controller.providerLoading.value == ApiCallStatus.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
          //   child: Text('Languages Spoken', style: TextStyle(fontSize: 13)),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              alignment: WrapAlignment.start,
              children:
                  ((controller.provider.value.languagesSpoken ?? []).isEmpty
                          ? ['Amharic', 'English']
                          : (controller.provider.value.languagesSpoken ?? []))
                      .map(
                        (lang) => Container(
                          // width: width,
                          // height: MediaQuery.of(Get.context!).size.height * 0.05,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language,
                                  color: ThemeModeController.isLightTheme.value
                                      ? Colors.blue[900]
                                      : Colors.blue,
                                ),
                                Text(
                                  lang.capitalizeFirst ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        ThemeModeController.isLightTheme.value
                                        ? Colors.blue[900]
                                        : Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkRadiusAndRate(BuildContext context) {
    return ShimmerWrapper(
      isEnabled: controller.providerLoading.value == ApiCallStatus.loading,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 8, left: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Icon(Icons.radar, color: Theme.of(context).primaryColor),
                  Text(
                    '${controller.provider.value.workRadius ?? 5}${'km_work_radius'.tr}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star_rate_rounded, color: Colors.amber),
                Text(
                  '${controller.provider.value.rating ?? 5}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProviderInfo(BuildContext context) {
    return ShimmerWrapper(
      isEnabled: controller.providerLoading.value == ApiCallStatus.loading,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: AutoSizeText(
                      controller.providerLoading.value == ApiCallStatus.loading
                          ? 'First name last'
                          : '${controller.provider.value.firstName ?? ''}${controller.provider.value.middleName ?? ''}',
                      maxFontSize: 16,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: AutoSizeText(
                          controller.providerLoading.value ==
                                  ApiCallStatus.loading
                              ? 'Kolfe Keraniyo, Addis Ababa, Wereda 10'
                              : '${controller.provider.value.subcity}, ${controller.provider.value.city}, Wereda ${controller.provider.value.woreda ?? ''}',
                          maxFontSize: 11,
                          minFontSize: 4,
                          maxLines: 2,
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            controller.providerLoading.value == ApiCallStatus.loading
                ? Icon(Icons.bookmark)
                : BookmarkButton(
                    isBookmarked: controller.isBookmarked.value,
                    isLoading: controller.bookmarkLoading.value,
                    onPressed: controller.toggleBookmark,
                  ),
          ],
        ),
      ),
    );
  }

  Row buildProfileImage(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
              child: cachedNetworkImageWrapper(
                imageUrl: controller.provider.value.profilePicture ?? '',
                // width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.3,
                // fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) {
                  return SmallCardImageHolder(
                    image: Image.network(
                      controller.provider.value.profilePicture ?? '',
                      // width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                placeholderBuilder: (context, string) {
                  return Container(
                    // width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: Colors.grey,
                  );
                },
                errorWidgetBuilder: (context, path, obj) {
                  return Container(
                    height: MediaQuery.of(context).size.width * 0.3,
                    // width: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                      // border: Border.all(
                      //   color: Theme.of(context).primaryColor,
                      // ),
                      // color: Theme.of(context).primaryColor,
                    ),
                    child: Icon(
                      Icons.person_2_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
