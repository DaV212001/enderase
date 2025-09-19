import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';

class CategoryDetailCard extends StatelessWidget {
  const CategoryDetailCard({
    super.key,
    required this.imageUrl,
    required this.categoryName,
    required this.certified,
    required this.pricePerHour,
    required this.experienceLevel,
    required this.isShimmer,
    this.onTap,
  });

  final String imageUrl;
  final String categoryName;
  final bool certified;
  final double pricePerHour;
  final String experienceLevel;
  final bool isShimmer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = MediaQuery.of(context).size.width * 0.15;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ShimmerWrapper(
            isEnabled: isShimmer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: radius,
                    height: radius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor),
                      // color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.network(
                        '$kApiBaseUrl/$imageUrl',
                        placeholderBuilder: (context) => Container(
                          height: radius,
                          width: radius,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.category,
                          color: Theme.of(context).primaryColor,
                        ),
                        fit: BoxFit.contain,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  // cachedNetworkImageWrapper(
                  //   imageUrl: imageUrl,
                  //   height: radius,
                  //   width: radius,
                  //   imageBuilder: (context, imageProvider) => CircularImageHolder(
                  //     image: Image.network(
                  //       imageUrl,
                  //       height: radius,
                  //       width: radius,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  //   placeholderBuilder: (context, string) {
                  //     return Container(
                  //       height: radius,
                  //       width: radius,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Theme.of(context).primaryColor,
                  //       ),
                  //     );
                  //   },
                  //   errorWidgetBuilder: (context, path, obj) {
                  //     return Container(
                  //       height: radius,
                  //       width: radius,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         border: Border.all(
                  //           color: Theme.of(context).primaryColor,
                  //         ),
                  //         // color: Theme.of(context).primaryColor,
                  //       ),
                  //       child: Icon(
                  //         Icons.category,
                  //         color: Theme.of(context).primaryColor,
                  //       ),
                  //     );
                  //   },
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: AutoSizeText(
                                categoryName,
                                maxFontSize: 15,
                                minFontSize: 9,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (certified)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.amber,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: AutoSizeText(
                                      'certified'.tr,
                                      maxFontSize: 10,
                                      minFontSize: 4,
                                      style: TextStyle(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AutoSizeText(
                              'ETB $pricePerHour/hour',
                              maxFontSize: 12,
                              minFontSize: 4,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Center(
                        child: Text(
                          experienceLevel,
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
