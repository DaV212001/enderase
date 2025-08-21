import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/controllers/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../../../setup_files/wrappers/shimmer_wrapper.dart';

class ProfessionalProviderCard extends StatelessWidget {
  const ProfessionalProviderCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.certificateNumber,
    required this.isShimmer,
  });

  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final int certificateNumber;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ShimmerWrapper(
        isEnabled: isShimmer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cachedNetworkImageWrapper(
              imageUrl: imageUrl,
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholderBuilder: (context, string) {
                return Container(
                  height: MediaQuery.of(context).size.width * 0.15,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
              errorWidgetBuilder: (context, path, obj) {
                return Container(
                  height: MediaQuery.of(context).size.width * 0.15,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).primaryColor),
                    // color: Theme.of(context).primaryColor,
                  ),
                  child: Icon(
                    Icons.person_2_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: AutoSizeText(
                        name,
                        maxFontSize: 14,
                        minFontSize: 9,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Obx(() {
                        return AutoSizeText(
                          location,
                          maxFontSize: 11,
                          minFontSize: 9,
                          maxLines: 2,
                          style: TextStyle(
                            color: ThemeModeController.isLightTheme.value
                                ? Colors.grey[700]!
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return AutoSizeText(
                            '$rating',
                            maxFontSize: 11,
                            minFontSize: 9,
                            style: TextStyle(
                              color: ThemeModeController.isLightTheme.value
                                  ? Colors.grey[700]!
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                        Obx(() {
                          return Icon(
                            Icons.star_rounded,
                            size: 10,
                            color: ThemeModeController.isLightTheme.value
                                ? Colors.grey[700]!
                                : Colors.grey,
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Obx(() {
                            return AutoSizeText(
                              '${certificateNumber > 3 ? '4+' : certificateNumber} ${'cert'.tr}',
                              maxFontSize: 11,
                              minFontSize: 9,
                              style: TextStyle(
                                color: ThemeModeController.isLightTheme.value
                                    ? Colors.grey[700]!
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
