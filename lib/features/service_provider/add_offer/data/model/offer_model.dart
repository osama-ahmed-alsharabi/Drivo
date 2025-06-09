class OfferModel {
  final String? id;
  final String restaurantId;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime endDate;

  OfferModel({
    required this.id,
    required this.restaurantId,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.endDate,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json["id"],
      restaurantId: json["restaurant_id"],
      imageUrl: json["image_url"],
      isActive: json["is_active"],
      createdAt: DateTime.parse(json["created_at"]),
      endDate: DateTime.parse(json["end_date"]),
    );
  }
  OfferModel copyWith({
    String? id,
    String? restaurantId,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? endDate,
  }) {
    return OfferModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson(OfferModel offer) {
    return {
      "restaurant_id": offer.restaurantId,
      'image_url': offer.imageUrl,
      "is_active": offer.isActive,
      "created_at": offer.createdAt.toIso8601String(),
      "end_date": offer.endDate.toIso8601String(),
    };
  }
}
