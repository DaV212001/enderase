import 'package:enderase/constants/pages.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../setup_files/wrappers/shimmer_wrapper.dart';

/// A widget that displays categories in a paginated grid format.
///
/// - Shows a shimmer loading state while fetching categories.
/// - Displays a "No categories" error state when there are no results.
/// - Renders categories in a 2-row, 3-column grid with paging support.
/// - Loads category icons from local assets (`assets/images/categories/{id}.svg`).
class CategoryGrid extends StatelessWidget {
  /// Creates a [CategoryGrid].
  ///
  /// [categoryController] - The controller that handles category data fetching.
  CategoryGrid({super.key});

  /// The category controller used to fetch and observe categories.
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Handle loading state
      if (categoryController.loadingCategory.value == ApiCallStatus.loading) {
        return _buildLoadingShimmer();
      }

      // Handle empty/error state
      if (categoryController.categories.isEmpty &&
          categoryController.loadingCategory.value != ApiCallStatus.loading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/errors/empty_list.svg',
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 10),
                Text('No categories found'),
                ElevatedButton(
                  onPressed: categoryController.fetchCategories,
                  child: Text('Refresh'),
                ),
              ],
            ),
          ),
        );
      }

      // Calculate number of pages
      final totalItems = categoryController.categories.length;
      final totalPages = (totalItems / 6).ceil();
      final pageController = PageController();

      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SizedBox(
          height: 240.h,
          child: Column(
            children: [
              // Main PageView
              Expanded(
                child: PageView.builder(
                  onPageChanged: (index) =>
                      categoryController.currentPage.value = index,
                  controller: categoryController.pageController,
                  itemCount: totalPages,
                  itemBuilder: (context, pageIndex) {
                    final start = pageIndex * 6;
                    final end = (start + 6).clamp(0, totalItems);
                    final pageItems = categoryController.categories.sublist(
                      start,
                      end,
                    );

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: pageItems.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.5,
                          ),
                      itemBuilder: (context, index) {
                        final category = pageItems[index];
                        final imagePath =
                            'assets/images/categories/${category.id}.svg';

                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.searchRoute,
                              arguments: category.id,
                            );
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SvgPicture.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.categoryName ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Page indicator
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: categoryController.currentPage.value == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingShimmer() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: 6, // Show placeholder for 6 items
        itemBuilder: (context, index) => ShimmerWrapper(
          isEnabled: true,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  width: 50,
                  height: 50,
                ),
              ),
              Text(
                'Electricity',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
