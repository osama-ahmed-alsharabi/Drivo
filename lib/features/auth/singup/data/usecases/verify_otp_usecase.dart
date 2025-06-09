import 'package:drivo_app/features/auth/singup/data/domain/repositories/signup_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpUseCase {
  final SignupRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<User> execute(String email, String token) async {
    return await repository.verifyOtp(email, token);
  }
}
