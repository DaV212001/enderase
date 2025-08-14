import 'package:enderase/controllers/category_controller.dart';
import 'package:enderase/controllers/city_controller.dart';
import 'package:enderase/models/category.dart';
import 'package:enderase/models/provider.dart';
import 'package:enderase/setup_files/api_call_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/search_screen_controller.dart';
import '../../../../widgets/cards/home/filter_chip.dart';
import '../../../../widgets/cards/provider/provider_search_card.dart';

class ProviderSearchFilterScreen extends StatelessWidget {
  final SearchScreenController providerController = Get.put(
    SearchScreenController(),
  );
  final CategoryController categoryController = Get.find();
  final CityController cityController = Get.put(CityController());

  final TextEditingController searchController = TextEditingController();

  ProviderSearchFilterScreen({super.key});

  void _applyNameSearch(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    providerController.applyFilters(
      firstName: parts.isNotEmpty ? parts[0] : '',
      middleName: parts.length > 1 ? parts[1] : '',
    );
  }

  void _showFullFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("All Filters"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _cityFilter(),
              const SizedBox(height: 12),
              _ratingFilter(),
              const SizedBox(height: 12),
              _radiusFilter(),
              const SizedBox(height: 12),
              _categoryFilter(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showDialogForFilter(BuildContext context, String label, Widget child) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: child,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: 'providerSearchHero',
          child: SizedBox(
            height: 50,
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: searchController,
                onSubmitted: _applyNameSearch,
                decoration: InputDecoration(
                  hintText: 'Search providers...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                ActionChip(
                  avatar: const Icon(Icons.filter_list, size: 18),
                  label: const Text("Filters", style: TextStyle(fontSize: 10)),
                  onPressed: () => _showFullFilterDialog(context),
                ),
                const SizedBox(width: 8),

                // City filter
                Obx(
                  () => FilterChipLike(
                    icon: Icons.location_city,
                    label: "City",
                    isActive: providerController.filterCityId.value != null,
                    onPressed: () =>
                        _showDialogForFilter(context, "City", _cityFilter()),
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
                    onPressed: () => _showDialogForFilter(
                      context,
                      "Rating",
                      _ratingFilter(),
                    ),
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
                    onPressed: () => _showDialogForFilter(
                      context,
                      "Radius",
                      _radiusFilter(),
                    ),
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
                    onPressed: () => _showDialogForFilter(
                      context,
                      "Category",
                      _categoryFilter(),
                    ),
                    onClear: providerController.filterCategoryId.value != null
                        ? () => providerController.clearFilter('category')
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Found count + Sort bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Obx(
                  () => Text(
                    "Found (${providerController.providers.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => DropdownButton<String>(
                    value: providerController.sort.value.isEmpty
                        ? null
                        : providerController.sort.value,
                    hint: const Text('Sort by', style: TextStyle(fontSize: 12)),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('None')),
                      DropdownMenuItem(
                        value: 'first_name',
                        child: Text('Name', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Rating', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'city',
                        child: Text('City', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (value) {
                      providerController.applyFilters(sortBy: value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Provider list with infinite scroll
          Expanded(
            child: Obx(() {
              if (providerController.loadingProviders.value ==
                  ApiCallStatus.loading) {
                return ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return ProviderSearchCard(
                      provider: Provider(
                        id: 0,
                        firstName: 'firstName',
                        middleName: 'middleName',
                        lastName: 'lastName',
                        profilePicture: 'profilePicture',
                        city: 'city',
                        subcity: 'subcity',
                        woreda: 'woreda',
                        rating: 3,
                        categories: [Category(categoryName: 'categoryName')],
                      ),
                      isShimmer: true,
                    );
                  },
                );
              }
              if (providerController.providers.isEmpty) {
                return const Center(child: Text('No providers found.'));
              }
              return ListView.builder(
                controller: providerController.scrollController,
                itemCount:
                    providerController.providers.length +
                    (providerController.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == providerController.providers.length) {
                    // Loading indicator at bottom for pagination
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final provider = providerController.providers[index];
                  return ProviderSearchCard(
                    provider: provider,
                    isShimmer: false,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Filters UI Widgets
  Widget _cityFilter() {
    return Obx(() {
      if (cityController.cityLoading.value == ApiCallStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return DropdownButton<int>(
        value: cityController.selectedCityId.value == 0
            ? null
            : cityController.selectedCityId.value,
        hint: const Text('Select City'),
        items: cityController.cities.map((city) {
          return DropdownMenuItem<int>(
            value: city.id!,
            child: Text(city.name ?? ""),
          );
        }).toList(),
        onChanged: (value) {
          cityController.selectedCityId.value = value ?? 0;
          providerController.applyFilters(cityId: value);
          Get.back();
        },
      );
    });
  }

  Widget _ratingFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          child: Icon(
            Icons.star,
            color: providerController.filterRating.value == index + 1
                ? Colors.amber
                : Colors.grey,
            size: 30,
          ),
          onTap: () {
            providerController.applyFilters(rating: index + 1);
            Get.back();
          },
        );
      }),
    );
  }

  Widget _radiusFilter() {
    return Obx(
      () => Slider(
        min: 1,
        max: 100,
        divisions: 10,
        value: (providerController.filterWorkRadius.value ?? 10).toDouble(),
        label: '${providerController.filterWorkRadius.value ?? 10} km',
        onChanged: (value) {
          providerController.applyFilters(workRadius: value.toInt());
        },
        onChangeEnd: (_) => Get.back(),
      ),
    );
  }

  Widget _categoryFilter() {
    return Obx(() {
      if (categoryController.loadingCategory.value == ApiCallStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return DropdownButton<int>(
        value: providerController.filterCategoryId.value,
        hint: const Text('Select Category'),
        items: categoryController.categories.map((cat) {
          return DropdownMenuItem<int>(
            value: cat.id!,
            child: Text(cat.categoryName ?? ''),
          );
        }).toList(),
        onChanged: (value) {
          providerController.applyFilters(categoryId: value);
          Get.back();
        },
      );
    });
  }
}
