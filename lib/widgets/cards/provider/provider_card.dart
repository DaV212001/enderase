import 'package:auto_size_text/auto_size_text.dart';
import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';
import '../home/rounded_container_list.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    required this.categoriesList,
    required this.isShimmer,
  });

  final String image;
  final String name;
  final String location;
  final double rating;
  final List<String> categoriesList;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7),
        // boxShadow: kCardShadow(),
      ),
      child: ShimmerWrapper(
        isEnabled: isShimmer,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                    imageUrl: image,
                    // width: MediaQuery.of(context).size.width * 0.4,
                    // height: MediaQuery.of(context).size.height * 0.15,
                    // fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) {
                      return SmallCardImageHolder(
                        image: Image.network(
                          image,
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.12,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                    placeholderBuilder: (context, string) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.12,
                        color: Colors.grey,
                      );
                    },
                    errorWidgetBuilder: (context, path, obj) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.12,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      name,
                      maxFontSize: 11,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
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
                          width: !isShimmer
                              ? MediaQuery.of(context).size.width * 0.35
                              : MediaQuery.of(context).size.width * 0.2,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, index) =>
                                  Icon(Icons.star_rounded, color: Colors.amber),
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
                    ),
                    if (!isShimmer) RoundedListWithCount(items: categoriesList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
