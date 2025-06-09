import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String userName,
    required String phoneNumber,
    required String city,
    required String directorate,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'user_name': userName,
        'phone_number': phoneNumber,
        'city': city,
        'directorate': directorate,
        'user_type': 'client',
      },
    );
    return response;
  }

  // Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    final response = await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'yourapp://auth-callback',
    );

    // Wait for session to be available
    await Future.delayed(const Duration(seconds: 1));

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Sign in failed');

    return AuthResponse(
      user: session.user,
      session: session,
    );
  }

  // Send OTP to email
  Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'yourapp://otp-callback',
    );
  }

  // Verify OTP
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
