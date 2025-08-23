import 'package:get/get.dart';

class Category {
  final int? id;
  final String? categoryNameEn;
  final String? categoryNameAm;
  final bool? certified;
  final String? hourlyRate;
  final String? skillLevel;
  final String? image;

  const Category({
    this.hourlyRate,
    this.skillLevel,
    this.image,
    this.categoryNameAm,
    this.certified,
    this.id,
    this.categoryNameEn,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryNameEn: json['category'],
      categoryNameAm: json['category_am'],
      certified: json['certified'] ?? false,
      image: json['icon_path'],
      hourlyRate: json['hourly_rate'] ?? '',
      skillLevel: json['skill_level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'category': categoryNameEn};

  String get categoryName {
    if (Get.locale!.languageCode == 'en') {
      return categoryNameEn!;
    } else {
      return categoryNameAm!;
    }
  }
}
