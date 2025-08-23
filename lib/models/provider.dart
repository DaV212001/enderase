import 'package:enderase/models/certifications.dart';
import 'package:get/get.dart';

import 'category.dart';

class Provider {
  final int? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? profilePicture;
  final String? cityEn;
  final String? subcityEn;
  final String? cityAm;
  final String? subCityAm;
  final String? woreda;
  final double? rating;
  final num? workRadius;
  final List<Category>? categories;
  final List<Certifications>? certifications;
  final List<String>? languagesSpoken;

  Provider({
    this.languagesSpoken,
    this.workRadius,
    this.cityAm,
    this.subCityAm,
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.profilePicture,
    this.cityEn,
    this.subcityEn,
    this.woreda,
    this.rating,
    this.categories,
    this.certifications,
  });

  static Provider sampleProvider = Provider(
    id: 1,
    firstName: 'Margot',
    middleName: 'Bartell',
    workRadius: 5,
    lastName: 'Bartell',
    profilePicture:
        'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
    cityEn: 'location',
    cityAm: 'location',
    subCityAm: 'location',
    subcityEn: '',
    woreda: '08',
    rating: 5,
    categories: [
      Category(
        id: 1,
        categoryNameAm: 'Nurse',
        categoryNameEn: 'Nurse',
        hourlyRate: '344.76',
        skillLevel: 'beginner',
      ),
      Category(
        id: 1,
        categoryNameAm: 'Nurse',
        categoryNameEn: 'Nurse',
        hourlyRate: '344.76',
        skillLevel: 'beginner',
      ),
      Category(
        id: 1,
        categoryNameAm: 'Nurse',
        categoryNameEn: 'Nurse',
        hourlyRate: '344.76',
        skillLevel: 'beginner',
      ),
    ],
    certifications: Certifications.certifications,
    languagesSpoken: ['amharic', 'english'],
  );

  static List<Provider> providers = [
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      lastName: 'Bartell',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      cityAm: 'location',
      subCityAm: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      lastName: 'Bartell',
      cityAm: 'location',
      subCityAm: 'location',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      cityAm: 'location',
      subCityAm: 'location',
      lastName: 'Bartell',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      lastName: 'Bartell',
      cityAm: 'location',
      subCityAm: 'location',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      lastName: 'Bartell',
      cityAm: 'location',
      subCityAm: 'location',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
    Provider(
      id: 1,
      firstName: 'Margot',
      middleName: 'Bartell',
      lastName: 'Bartell',
      cityAm: 'location',
      subCityAm: 'location',
      profilePicture:
          'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?cs=srgb&dl=pexels-hannah-nelson-390257-1065084.jpg&fm=jpg',
      cityEn: 'location',
      subcityEn: '',
      woreda: '08',
      rating: 5,
      categories: [
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
        Category(id: 1, categoryNameAm: 'Nurse', categoryNameEn: 'Nurse'),
      ],
      certifications: Certifications.certifications,
    ),
  ];

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] ?? 0,
      firstName: (json['first_name'] ?? 'Unknown') + ' ',
      middleName: json['middle_name'] ?? 'Unknown',
      lastName: json['last_name'] ?? 'Unknown',
      profilePicture: json['profile_picture'] ?? '',
      cityEn: json['city'] ?? '',
      cityAm: json['city_am'] ?? '',
      subcityEn: json['subcity'] ?? '',
      subCityAm: json['subcity_am'] ?? '',
      woreda: json['woreda'] ?? '',
      workRadius: json['work_radius'] ?? 0.0,
      rating: json['rating'] == null
          ? 0.0
          : json['rating'] is double
          ? json['rating']
          : double.tryParse('${json['rating']}') ?? 0,
      categories: json['categories'] == null
          ? []
          : (json['categories'] as List?)
                    ?.map((c) => Category.fromJson(c))
                    .toList() ??
                [],
      certifications: json['certifications'] == null
          ? []
          : (json['certifications'] as List?)
                    ?.map((c) => Certifications.fromJson(c))
                    .toList() ??
                [],
      languagesSpoken: ((json['languages_spoken'] ?? []) as List)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'middle_name': middleName,
    'last_name': lastName,
    'profile_picture': profilePicture,
    'city': city,
    'subcity': subcityEn,
    'woreda': woreda,
    'rating': rating,
    'categories': categories?.map((c) => c.toJson()).toList(),
  };

  String get city {
    if (Get.locale!.languageCode == 'en') {
      return cityEn ?? '';
    } else {
      return cityAm ?? "";
    }
  }

  String get subcity {
    if (Get.locale!.languageCode == 'en') {
      return subcityEn ?? "";
    } else {
      return subCityAm ?? "";
    }
  }
}
