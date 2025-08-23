import 'package:enderase/setup_files/wrappers/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

import '../../../setup_files/wrappers/cached_image_widget_wrapper.dart';

class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificationImage,
    required this.certificateName,
    required this.isShimmer,
  });

  final String certificationImage;
  final String certificateName;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ShimmerWrapper(
        isEnabled: isShimmer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
                child: cachedNetworkImageWrapper(
                  imageUrl: certificationImage,
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.12,
                  // fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) {
                    return SmallCardImageHolder(
                      image: Image.network(
                        certificationImage,
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
                      height: MediaQuery.of(context).size.width * 0.12,
                      width: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        // color: Theme.of(context).primaryColor,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(certificateName),
          ],
        ),
      ),
    );
  }
}
