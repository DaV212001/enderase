import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterChipLike extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final VoidCallback? onClear;

  const FilterChipLike({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      color: isActive ? Theme.of(context).primaryColor : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 10,
                ),
              ),
              if (isActive && onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.translucent,
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// Filter chip row usage
// =====================
class FilterChipRow extends StatelessWidget {
  final dynamic providerController;
  final Function(BuildContext, String, Widget) _showDialogForFilter;
  final Widget _cityFilter;
  final Widget _ratingFilter;
  final Widget _radiusFilter;
  final Widget _categoryFilter;

  const FilterChipRow({
    super.key,
    required this.providerController,
    required Function(BuildContext, String, Widget) showDialogForFilter,
    required Widget cityFilter,
    required Widget ratingFilter,
    required Widget radiusFilter,
    required Widget categoryFilter,
  }) : _showDialogForFilter = showDialogForFilter,
       _cityFilter = cityFilter,
       _ratingFilter = ratingFilter,
       _radiusFilter = radiusFilter,
       _categoryFilter = categoryFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          const SizedBox(width: 8),

          // City filter
          Obx(
            () => FilterChipLike(
              icon: Icons.location_city,
              label: "City",
              isActive: providerController.filterCityId.value != null,
              onPressed: () =>
                  _showDialogForFilter(context, "City", _cityFilter),
              onClear: providerController.filterCityId.value != null
                  ? () => providerController.clearFilter('city')
                  : null,
            ),
          ),

          const SizedBox(width: 8),

          // Rating filter
          Obx(
            () => FilterChipLike(
              icon: Icons.star,
              label: "Rating",
              isActive: providerController.filterRating.value != null,
              onPressed: () =>
                  _showDialogForFilter(context, "Rating", _ratingFilter),
              onClear: providerController.filterRating.value != null
                  ? () => providerController.clearFilter('rating')
                  : null,
            ),
          ),

          const SizedBox(width: 8),

          // Radius filter
          Obx(
            () => FilterChipLike(
              icon: Icons.radio_button_checked,
              label: "Radius",
              isActive: providerController.filterWorkRadius.value != null,
              onPressed: () =>
                  _showDialogForFilter(context, "Radius", _radiusFilter),
              onClear: providerController.filterWorkRadius.value != null
                  ? () => providerController.clearFilter('radius')
                  : null,
            ),
          ),

          const SizedBox(width: 8),

          // Category filter
          Obx(
            () => FilterChipLike(
              icon: Icons.category,
              label: "Category",
              isActive: providerController.filterCategoryId.value != null,
              onPressed: () =>
                  _showDialogForFilter(context, "Category", _categoryFilter),
              onClear: providerController.filterCategoryId.value != null
                  ? () => providerController.clearFilter('category')
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
