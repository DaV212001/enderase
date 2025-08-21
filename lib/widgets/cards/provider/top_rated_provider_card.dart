import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../home/rounded_container_list.dart';

class TopRatedProviderCard extends StatelessWidget {
  const TopRatedProviderCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.listOfCategories,
    required this.isShimmer,
  });

  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final List<String> listOfCategories;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7),
      ),
      margin: EdgeInsets.only(right: 8),
      width: MediaQuery.of(context).size.width * 0.7,
      child: ShimmerWrapper(
        isEnabled: isShimmer,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cachedNetworkImageWrapper(
                    imageUrl: imageUrl,
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    imageBuilder: (context, imageProvider) =>
                        CircularImageHolder(
                          image: Image.network(
                            imageUrl,
                            height: MediaQuery.of(context).size.width * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                    placeholderBuilder: (context, string) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    errorWidgetBuilder: (context, path, obj) {
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.15,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: AutoSizeText(
                              name,
                              maxFontSize: 13,
                              minFontSize: 9,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 15,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: AutoSizeText(
                                location,
                                maxFontSize: 10,
                                minFontSize: 4,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                                top: 2.0,
                              ),
                              child: RatingBarIndicator(
                                rating: rating,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 15.0,
                                direction: Axis.horizontal,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: AutoSizeText(
                                '$rating',
                                maxFontSize: 11,
                                minFontSize: 7,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isShimmer)
                Padding(
                  padding: const EdgeInsets.only(top: 9.0, bottom: 4),
                  child: RoundedListWithCount(items: listOfCategories),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
