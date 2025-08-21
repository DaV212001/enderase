import 'package:get/get.dart';

class SubCity {
  final int? id;
  final String? nameEn;
  final String? nameAm;

  const SubCity({this.nameAm, this.id, this.nameEn});

  factory SubCity.fromJson(Map<String, dynamic> json) {
    return SubCity(
      id: json['id'],
      nameEn: json['subcity_name'],
      nameAm: json['subcity_name_am'],
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
