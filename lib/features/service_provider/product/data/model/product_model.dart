// product_model.dart
import 'dart:convert';

class ProductModel {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final bool isAvailable;
  final String? imageUrl;
  final String restaurantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? exchangeRate;

  ProductModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    required this.isAvailable,
    this.imageUrl,
    required this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.exchangeRate,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
    String? imageUrl,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? exchangeRate,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown', // Default value
      description: json['description'] as String?,
      price: (json['price'] ?? 0.0) is int
          ? (json['price'] as int).toDouble()
          : (json['price'] as double? ?? 0.0),
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      restaurantId: json['restaurant_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory ProductModel.fromJsonString(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      print('Error parsing ProductModel from JSON string: $e');
      // Return a default product
      return ProductModel(
        name: 'Unknown',
        price: 0.0,
        isAvailable: false,
        restaurantId: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (category != null) 'category': category,
      'is_available': isAvailable,
      if (imageUrl != null) 'image_url': imageUrl,
      'restaurant_id': restaurantId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
