import 'package:enderase/models/category.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/cards/category/category_card_for_provider_detail.dart';

class CategorySelection extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onCategorySelected;
  const CategorySelection({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'select_occupation'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...(categories ?? []).map((cat) {
                return CategoryDetailCard(
                  imageUrl: cat.image ?? '',
                  categoryName: cat.categoryName,
                  certified: cat.certified ?? false,
                  pricePerHour: double.parse(cat.hourlyRate ?? '0.0'),
                  experienceLevel: (cat.skillLevel ?? '').capitalizeFirst ?? '',
                  isShimmer: false,
                  onTap: () => onCategorySelected(cat),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
