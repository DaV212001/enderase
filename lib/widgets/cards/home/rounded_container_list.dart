import 'package:enderase/constants/constants.dart';
import 'package:enderase/controllers/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoundedListWithCount extends StatelessWidget {
  final List<String> items;

  const RoundedListWithCount({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.19;

    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> visibleItems = [];
        if (items.length <= 3) {
          visibleItems = items
              .map((item) => _buildItem(item, itemWidth))
              .toList();
        } else {
          visibleItems = [
            _buildItem(items[0], itemWidth),
            _buildItem(items[1], itemWidth),
            _buildItem("+${items.length - 2} more", itemWidth, isMore: true),
          ];
        }

        return Wrap(spacing: 8, runSpacing: 2, children: visibleItems);
      },
    );
  }

  Widget _buildItem(String text, double width, {bool isMore = false}) {
    return Container(
      // width: width,
      // height: MediaQuery.of(Get.context!).size.height * 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isMore
            ? Colors.transparent
            : AppConstants.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      // alignment: Alignment.center,
      child: Obx(() {
        return Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isMore
                ? Colors.grey
                : ThemeModeController.isLightTheme.value
                ? Colors.blue[900]
                : Colors.blue,
            fontSize: 9,
          ),
        );
      }),
    );
  }
}
