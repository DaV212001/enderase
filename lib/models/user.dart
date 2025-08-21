class User {
  final int? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? profilePicture;
  final String? fanNumber;
  final String? primaryPhone;
  final String? secondaryPhone;
  final String? landlinePhone;
  final String? city;
  final String? subcity;
  final String? woreda;
  final String? houseNumber;
  final bool? approved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? deletedAt;

  const User({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.profilePicture,
    this.fanNumber,
    this.primaryPhone,
    this.secondaryPhone,
    this.landlinePhone,
    this.city,
    this.subcity,
    this.woreda,
    this.houseNumber,
    this.approved,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      fanNumber: json['fan_number'],
      primaryPhone: json['primary_phone'],
      secondaryPhone: json['secondary_phone'],
      landlinePhone: json['landline_phone'],
      city: json['city'],
      subcity: json['subcity'],
      woreda: json['woreda'],
      houseNumber: json['house_number'],
      approved: json['approved'],
      // createdAt: DateTime.parse(json['created_at']),
      // updatedAt: DateTime.parse(json['updated_at']),
      // deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'fan_number': fanNumber,
      'primary_phone': primaryPhone,
      'secondary_phone': secondaryPhone,
      'landline_phone': landlinePhone,
      'city': city,
      'subcity': subcity,
      'woreda': woreda,
      'house_number': houseNumber,
      'approved': approved,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deleted_at': deletedAt,
    };
  }
}
