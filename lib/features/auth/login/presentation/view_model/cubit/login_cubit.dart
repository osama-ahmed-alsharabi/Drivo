import 'dart:developer';

import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/auth/login/presentation/view_model/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loginWithEmail(String email, String password) async {
    emit(LoginLoading());
    try {
      // Validate email and password first
      if (email.isEmpty || password.isEmpty) {
        emit(LoginFailure('البريد الإلكتروني وكلمة المرور مطلوبان'));
        return;
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user == null) {
        emit(LoginFailure('فشل تسجيل الدخول'));
        return;
      }

      // Check user type in parallel for better performance
      final futures = await Future.wait([
        _supabase.from('clients').select().eq('email', email).maybeSingle(),
        _supabase.from('facilities').select().eq('email', email).maybeSingle(),
        _supabase.from('delivery').select().eq('email', email).maybeSingle(),
      ], eagerError: true);

      final clientData = futures[0];
      final providerData = futures[1];
      final deliveryData = futures[2];

      if (clientData != null && clientData.isNotEmpty) {
        await SharedPreferencesService.saveUserType("client");
        await SharedPreferencesService.saveUserId(clientData["id"]);
        await SharedPreferencesService.saveUserName(clientData["user_name"]);
        await SharedPreferencesService.saveUserPhone(
            clientData["phone_number"]);
        await SharedPreferencesService.saveEmail(clientData["email"]);
        emit(LoginSuccessClient());
      } else if (providerData != null &&
          providerData.isNotEmpty &&
          (providerData["is_active"] ?? false)) {
        await SharedPreferencesService.saveUserType("provider");
        await SharedPreferencesService.saveUserId(providerData["id"]);
        await SharedPreferencesService.saveUserName(
            providerData["facility_name"]);
        await SharedPreferencesService.saveUserPhone(
            providerData["phone_number"]);
        await SharedPreferencesService.saveEmail(providerData["email"]);

        emit(LoginSuccessPorvider());
      } else if (deliveryData != null &&
          deliveryData.isNotEmpty &&
          (deliveryData["is_active"] ?? false)) {
        await SharedPreferencesService.saveUserType("delivery");
        await SharedPreferencesService.saveUserId(deliveryData["id"]);
        await SharedPreferencesService.saveUserName(deliveryData["user_name"]);
        await SharedPreferencesService.saveUserPhone(
            deliveryData["phone_number"]);
        await SharedPreferencesService.saveEmail(deliveryData["email"]);
        emit(LoginSuccessDelivery());
      } else {
        emit(LoginFailure("لم يتم تنشيط الحساب بعد"));
      }
    } on AuthException catch (e) {
      _handleAuthError(e);
    } on PostgrestException catch (e) {
      log('Database error: ${e.message}');
      emit(LoginFailure('حدث خطأ في قاعدة البيانات'));
    } catch (e, st) {
      log('Unexpected error', error: e, stackTrace: st);
      emit(LoginFailure('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'));
    }
  }

  void _handleAuthError(AuthException e) {
    String errorMessage;

    switch (e.message) {
      case 'Invalid login credentials':
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        break;
      case 'Email not confirmed':
        errorMessage = 'الرجاء تأكيد البريد الإلكتروني أولاً';
        break;
      case 'Email rate limit exceeded':
        errorMessage = 'عدد محاولات كثيرة. يرجى المحاولة لاحقاً';
        break;
      case 'Network request failed':
        errorMessage = 'خطأ في الاتصال بالإنترنت';
        break;
      default:
        errorMessage = 'فشل تسجيل الدخول: ${e.message}';
    }

    emit(LoginFailure(errorMessage));
  }
}
