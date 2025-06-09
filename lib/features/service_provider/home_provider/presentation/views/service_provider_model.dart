class ServiceProviderModel {
  final String id;
  final String userName;
  final String phoneNumber;
  final String directorate;
  final String facilityName;
  final String facilityCategory;
  final DateTime createdAt;
  final String email;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final String? address;

  ServiceProviderModel({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.directorate,
    required this.facilityName,
    required this.facilityCategory,
    required this.createdAt,
    required this.email,
    required this.isActive,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'],
      userName: json['user_name'],
      phoneNumber: json['phone_number'],
      directorate: json['directorate'],
      facilityName: json['facility_name'],
      facilityCategory: json['facility_category'],
      createdAt: DateTime.parse(json['created_at']),
      email: json['email'],
      isActive: json['is_active'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'phone_number': phoneNumber,
      'directorate': directorate,
      'facility_name': facilityName,
      'facility_category': facilityCategory,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'is_active': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
