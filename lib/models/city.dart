class City {
  final int? id;
  final String? name;

  const City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'], name: json['city_name']);
  }
}
