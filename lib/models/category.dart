class Category {
  final int? id;
  final String? categoryName;
  final bool? certified;

  const Category({this.certified, this.id, this.categoryName});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['category'],
      certified: json['certified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'category': categoryName};
}
