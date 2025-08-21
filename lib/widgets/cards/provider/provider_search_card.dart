import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../constants/constants.dart';
import '../../../models/provider.dart';
import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';

class ProviderSearchCard extends StatelessWidget {
  const ProviderSearchCard({
    super.key,
    required this.provider,
    required this.isShimmer,
  });

  final Provider provider;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Logger().d('Tapped');
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              // border: Border(
              //   bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
              // ),
            ),
            child: ShimmerWrapper(
              isEnabled: isShimmer,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  leading: cachedNetworkImageWrapper(
                    imageUrl: provider.profilePicture ?? '',
                    height: MediaQuery.of(context).size.width * 0.12,
                    width: MediaQuery.of(context).size.width * 0.12,
                    imageBuilder: (context, imageProvider) =>
                        CircularImageHolder(
                          image: Image.network(
                            provider.profilePicture ?? '',
                            height: MediaQuery.of(context).size.width * 0.12,
                            width: MediaQuery.of(context).size.width * 0.12,
                            fit: BoxFit.cover,
                          ),
                        ),
                    placeholderBuilder: (context, string) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.12,
                        width: MediaQuery.of(context).size.width * 0.12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    errorWidgetBuilder: (context, path, obj) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.12,
                        width: MediaQuery.of(context).size.width * 0.12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          // color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(
                          Icons.person_2_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                  title: Text(
                    "${provider.firstName}${provider.middleName} ${provider.lastName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 30),
                      Text(
                        '${provider.rating}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          " ${provider.subcity}, ${provider.city}",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      if ((provider.categories ?? []).isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: (provider.categories ?? [])
                              .map(
                                (cat) => Container(
                                  // width: width,
                                  // height: MediaQuery.of(Get.context!).size.height * 0.05,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  // alignment: Alignment.center,
                                  child: Text(
                                    cat.categoryName ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                  onTap: null,
                ),
              ),
            ),
          ),
          Divider(thickness: 0.5, height: 1),
        ],
      ),
    );
  }
}
