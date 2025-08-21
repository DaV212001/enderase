class Certifications {
  final String? name;
  final String? image;

  Certifications({this.name, this.image});

  static List<Certifications> certifications = [
    Certifications(name: 'Nurse', image: ''),
    Certifications(name: 'Nurse', image: ''),
  ];

  factory Certifications.fromJson(Map<String, dynamic> json) {
    return Certifications(
      name: json['name'] ?? '',
      image: json['file_path'] ?? '',
    );
  }
}
