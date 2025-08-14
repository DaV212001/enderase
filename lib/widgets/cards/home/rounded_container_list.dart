import 'package:enderase/constants/constants.dart';
import 'package:flutter/material.dart';

class RoundedListWithCount extends StatelessWidget {
  final List<String> items;

  const RoundedListWithCount({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.19;

    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> visibleItems = [];
        if (items.length <= 2) {
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

        return Wrap(spacing: 8, runSpacing: 8, children: visibleItems);
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isMore ? Colors.grey : Colors.blue[900],
          fontSize: 9,
        ),
      ),
    );
  }
}
