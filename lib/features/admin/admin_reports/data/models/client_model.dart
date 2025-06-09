class ClientModel {
  final String id;
  final String userName;
  final String phoneNumber;
  final String createdAt;
  final String updatedAt;

  ClientModel(
      {required this.id,
      required this.userName,
      required this.phoneNumber,
      required this.createdAt,
      required this.updatedAt});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
        id: json['id'],
        userName: json['user_name'],
        phoneNumber: json["phone_number"],
        createdAt: json["created_at"],
        updatedAt: json['updated_at']);
  }
}
