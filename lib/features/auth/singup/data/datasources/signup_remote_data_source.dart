import 'package:drivo_app/core/service/auth_service.dart';
import 'package:drivo_app/features/auth/singup/data/model/signup_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupRemoteDataSource {
  final SupabaseService supabaseService;

  SignupRemoteDataSource({required this.supabaseService});

  Future<User> signup(SignupModel signupModel) async {
    final response = await supabaseService.signUp(
      email: signupModel.email,
      password: signupModel.password,
      userName: signupModel.userName,
      phoneNumber: signupModel.phoneNumber,
      city: signupModel.city,
      directorate: signupModel.directorate,
    );
    return response.user!;
  }

  Future<void> sendOtp(String email) async {
    await supabaseService.sendOtp(email);
  }

  Future<User> verifyOtp(String email, String token) async {
    final response = await supabaseService.verifyOtp(
      email: email,
      token: token,
    );
    return response.user!;
  }
}
