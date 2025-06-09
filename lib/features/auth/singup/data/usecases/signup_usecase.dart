import 'package:drivo_app/features/auth/singup/data/domain/repositories/signup_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupUseCase {
  final SignupRepository repository;

  SignupUseCase({required this.repository});

  Future<User> execute({
    required String email,
    required String password,
    required String userName,
    required String phoneNumber,
    required String city,
    required String directorate,
  }) async {
    return await repository.signup(
      email: email,
      password: password,
      userName: userName,
      phoneNumber: phoneNumber,
      city: city,
      directorate: directorate,
    );
  }
}
