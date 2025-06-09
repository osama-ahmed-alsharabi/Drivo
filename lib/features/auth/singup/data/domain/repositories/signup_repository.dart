import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SignupRepository {
  Future<User> signup({
    required String email,
    required String password,
    required String userName,
    required String phoneNumber,
    required String city,
    required String directorate,
  });

  Future<void> sendOtp(String email);
  Future<User> verifyOtp(String email, String token);
}
