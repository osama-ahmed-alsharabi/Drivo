class SignupModel {
  final String email;
  final String password;
  final String userName;
  final String phoneNumber;
  final String city;
  final String directorate;

  SignupModel({
    required this.email,
    required this.password,
    required this.userName,
    required this.phoneNumber,
    required this.city,
    required this.directorate,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'user_name': userName,
        'phone_number': phoneNumber,
        'city': city,
        'directorate': directorate,
      };
}
