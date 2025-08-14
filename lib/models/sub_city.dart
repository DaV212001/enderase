class SubCity {
  final int? id;
  final String? name;

  const SubCity({this.id, this.name});

  factory SubCity.fromJson(Map<String, dynamic> json) {
    return SubCity(id: json['id'], name: json['subcity_name']);
  }
}
