import 'package:get/get.dart';

class RuleSchema {
  final String key;
  final String rules;

  RuleSchema({required this.key, required this.rules});

  factory RuleSchema.fromJson(Map<String, dynamic> json) {
    return RuleSchema(key: json['key'], rules: json['rules']);
  }

  Map<String, dynamic> toJson() => {'key': key, 'rules': rules};

  // Type helpers
  bool get isRequired => rules.split('|').contains('required');
  bool get isArray => rules.split('|').contains('array');
  bool get isBoolean => rules.split('|').contains('boolean');
  bool get isString => rules.split('|').contains('string');
  bool get isNumber => rules.contains('numeric') || rules.contains('integer');

  // meta: "key.*" item rule
  bool get isItemRule => key.endsWith('.*');
  String get baseKey => isItemRule ? key.substring(0, key.length - 2) : key;

  int? get maxLength {
    final match = RegExp(r'max:(\d+)').firstMatch(rules);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  int? get min {
    final match = RegExp(r'min:(\d+)').firstMatch(rules);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  int? get max {
    final matches = RegExp(r'max:(\d+)').allMatches(rules).toList();
    if (matches.isEmpty) return null;
    return int.parse(matches.last.group(1)!);
  }

  /// options from `in:a,b,c`
  List<String> get options {
    // More specific pattern that won't match other rules like 'min:'
    final m = RegExp(r'\bin:([a-zA-Z0-9_,-]+)\b').firstMatch(rules);
    if (m == null) return [];
    return m.group(1)!.split(',').map((e) => e.trim()).toList();
  }

  String get label => baseKey.tr; // use base key for translation label
}

class Category {
  final int? id;
  final String? categoryNameEn;
  final String? categoryNameAm;
  final bool? certified;
  final String? hourlyRate;
  final String? skillLevel;
  final String? image;
  final List<RuleSchema>? rulesSchema;

  const Category({
    this.hourlyRate,
    this.skillLevel,
    this.image,
    this.categoryNameAm,
    this.certified,
    this.id,
    this.categoryNameEn,
    this.rulesSchema,
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
      rulesSchema: json.containsKey('rules_schema')
          ? (json['rules_schema'] as List<dynamic>?)
                    ?.map((e) => RuleSchema.fromJson(e))
                    .toList() ??
                []
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': categoryNameEn,
    'rules_schema': rulesSchema?.map((e) => e.toJson()).toList(),
  };

  String get categoryName {
    if (Get.locale!.languageCode == 'en') {
      return categoryNameEn ?? '';
    } else {
      return categoryNameAm ?? '';
    }
  }
}
