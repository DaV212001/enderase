class RatingModel {
  final int? id;
  final int? clientId;
  final int? providerId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? updatedAt;

  RatingModel({
    this.id,
    this.clientId,
    this.providerId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      clientId: json['client_id'] is String
          ? int.tryParse(json['client_id'])
          : json['client_id'],
      providerId: json['provider_id'] is String
          ? int.tryParse(json['provider_id'])
          : json['provider_id'],
      rating: (json['rating'] is String)
          ? int.tryParse(json['rating']) ?? 0
          : (json['rating'] ?? 0),
      comment: (json['comment'] ?? '').toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


