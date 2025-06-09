class FacilityModel {
  final String? id;
  final String userName;
  final String facilityName;
  final String email;
  final String phoneNumber;
  final String directorate;
  final String facilityCategory;
  final DateTime createAt;
  final DateTime updateAt;
  final bool isActive;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final String coverImage;
  final String logoUrl;
  final String openingHoursSunThu;
  final String closingHoursSunThu;
  final String openingHoursFri;
  final String closingHoursFri;
  final String openingHoursSat;
  final String closingHoursSat;

  FacilityModel({
    required this.id,
    required this.userName,
    required this.facilityName,
    required this.email,
    required this.phoneNumber,
    required this.directorate,
    required this.facilityCategory,
    required this.createAt,
    required this.updateAt,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    required this.coverImage,
    required this.logoUrl,
    required this.openingHoursSunThu,
    required this.closingHoursSunThu,
    required this.openingHoursFri,
    required this.closingHoursFri,
    required this.openingHoursSat,
    required this.closingHoursSat,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] as String?,
      userName: json['user_name'] as String,
      facilityName: json['facility_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      directorate: json['directorate'] as String,
      facilityCategory: json['facility_category'] as String,
      createAt: DateTime.parse(json['created_at'] as String),
      updateAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      description: json['description'] as String,
      coverImage: json['cover_image_url'] as String,
      logoUrl: json['logo_url'] as String,
      openingHoursSunThu: json['opening_hours_sun_thu'] as String,
      closingHoursSunThu: json['closing_hours_sun_thu'] as String,
      openingHoursFri: json['opening_hours_fri'] as String,
      closingHoursFri: json['closing_hours_fri'] as String,
      openingHoursSat: json['opening_hours_sat'] as String,
      closingHoursSat: json['closing_hours_sat'] as String,
    );
  }
}
