import 'package:drivo_app/features/auth/singup/data/datasources/signup_remote_data_source.dart';
import 'package:drivo_app/features/auth/singup/data/domain/repositories/signup_repository.dart';
import 'package:drivo_app/features/auth/singup/data/model/signup_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource remoteDataSource;

  SignupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String userName,
    required String phoneNumber,
    required String city,
    required String directorate,
  }) async {
    return await remoteDataSource.signup(
      SignupModel(
        email: email,
        password: password,
        userName: userName,
        phoneNumber: phoneNumber,
        city: city,
        directorate: directorate,
      ),
    );
  }

  @override
  Future<void> sendOtp(String email) async {
    await remoteDataSource.sendOtp(email);
  }

  @override
  Future<User> verifyOtp(String email, String token) async {
    return await remoteDataSource.verifyOtp(email, token);
  }
}
