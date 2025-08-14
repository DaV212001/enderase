import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../models/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    Logger().d(category.categoryName);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Expanded(
        //   child: SvgPicture.asset(
        //     "assets/images/categories/${category.id}.svg",
        //     width: 10,
        //     height: 10,
        //   ),
        // ),
        const SizedBox(height: 4),
        Text(
          category.categoryName!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
