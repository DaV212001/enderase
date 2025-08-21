import 'package:get/get.dart';

class City {
  final int? id;
  final String? nameEn;
  final String? nameAm;

  const City({this.nameAm, this.id, this.nameEn});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      nameEn: json['city_name'],
      nameAm: json['city_name_am'],
    );
  }

  String get name {
    if (Get.locale!.languageCode == 'en') {
      return nameEn!;
    } else {
      return nameAm!;
    }
  }
}
