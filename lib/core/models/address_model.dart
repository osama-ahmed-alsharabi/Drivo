// lib/features/address/models/address_model.dart
class Address {
  final int? id;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? additionalInfo;

  Address({
    this.id,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
      'additional_info': additionalInfo,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      isDefault: map['is_default'] == 1,
      additionalInfo: map['additional_info'],
    );
  }
}
