import 'category.dart';

class Provider {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? profilePicture;
  final String city;
  final String subcity;
  final String woreda;
  final int rating;
  final List<Category> categories;

  Provider({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.profilePicture,
    required this.city,
    required this.subcity,
    required this.woreda,
    required this.rating,
    required this.categories,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] ?? 0,
      firstName: (json['first_name'] ?? 'Unknown') + ' ',
      middleName: json['middle_name'] ?? 'Unknown',
      lastName: json['last_name'] ?? 'Unknown',
      profilePicture: json['profile_picture'],
      city: json['city'] ?? '',
      subcity: json['subcity'] ?? '',
      woreda: json['woreda'] ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse('${json['rating']}') ?? 0,
      categories:
          (json['categories'] as List?)
              ?.map((c) => Category.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'middle_name': middleName,
    'last_name': lastName,
    'profile_picture': profilePicture,
    'city': city,
    'subcity': subcity,
    'woreda': woreda,
    'rating': rating,
    'categories': categories.map((c) => c.toJson()).toList(),
  };
}
