import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../constants/pages.dart';
import '../../../models/provider.dart';
import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';

class FavoriteProviderCard extends StatelessWidget {
  const FavoriteProviderCard({
    super.key,
    required this.provider,
    required this.isShimmer,
    required this.onRemove,
    this.isRemoving = false,
  });

  final Provider provider;
  final bool isShimmer;
  final VoidCallback onRemove;
  final bool isRemoving;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isShimmer) {
          Get.toNamed(AppRoutes.providerDetailRoute, arguments: provider.id);
        }
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          Text(
                            '${provider.rating}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Remove button
                      if (!isShimmer)
                        GestureDetector(
                          onTap: isRemoving ? null : onRemove,
                          child: isRemoving
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.bookmark,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          "${provider.subcity}, ${provider.city}",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      if ((provider.categories ?? []).isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: (provider.categories ?? [])
                              .map(
                                (cat) => Container(
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
