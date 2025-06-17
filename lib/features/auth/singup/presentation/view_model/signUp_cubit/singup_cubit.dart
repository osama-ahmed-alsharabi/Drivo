import 'dart:async';
import 'dart:math';
import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/service/notification_services.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final SupabaseClient _supabase = Supabase.instance.client;
  String? _pendingUserId;
  Map<String, dynamic>? _pendingUserData;

  Future<void> signup({
    required String email,
    required String password,
    required String userName,
    required String phoneNumber,
    required String directorate,
    required String userType,
    String? facilityName,
    String? facilityCategory,
    String? deliveryLicense,
    required BuildContext context,
  }) async {
    emit(SignupLoading());
    try {
      final isPhoneUnique = await _isPhoneNumberUnique(phoneNumber);
      if (!isPhoneUnique) {
        if (!context.mounted) return;
        CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.fail,
          label: 'رقم الهاتف مسجل مسبقاً في نظامنا',
        );
        emit(SignupFailure('Phone number already exists'));
        return;
      }

      // 3. Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('فشل إنشاء المستخدم');
      }

      // 4. Store user data temporarily
      _pendingUserId = authResponse.user!.id;
      _pendingUserData = {
        'email': email,
        'user_name': userName,
        'phone_number': phoneNumber,
        'directorate': directorate,
        'user_type': userType,
        if (userType == 'facility') ...{
          'facility_name': facilityName,
          'facility_category': facilityCategory,
        },
        if (userType == 'delivery') ...{
          'delivery_license': deliveryLicense,
        },
      };

      // 5. Generate and store OTP
      final otpCode = _generateOtp();
      await _supabase.from('pending_users').upsert({
        'user_id': _pendingUserId,
        'email': email,
        'phone_number': phoneNumber,
        'otp_code': otpCode,
        'user_data': _pendingUserData,
        'expires_at':
            DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // 6. Send OTP via notification
      await _sendOtpNotification(otpCode, phoneNumber);

      emit(SignupSuccess(phoneNumber: phoneNumber));
    } on AuthException catch (e) {
      if (!context.mounted) return;
      _handleAuthError(e, context);
      emit(SignupFailure(e.message));
    } catch (e) {
      if (!context.mounted) return;
      _handleGenericError(e, context);
      emit(SignupFailure(e.toString()));
    }
  }

  Future<bool> _isPhoneNumberUnique(String phoneNumber) async {
    try {
      final results = await Future.wait([
        _supabase.from('clients').select().eq('phone_number', phoneNumber),
        _supabase.from('facilities').select().eq('phone_number', phoneNumber),
        _supabase.from('delivery').select().eq('phone_number', phoneNumber),
      ]);
      return results.every((result) => result.isEmpty);
    } catch (e) {
      throw Exception('فشل التحقق من رقم الهاتف: ${e.toString()}');
    }
  }

  // bool _isValidPhoneNumber(String phoneNumber) {
  //   // Basic validation - adjust according to your requirements
  //   final regex = RegExp(r'^[0-9]{10,15}$');
  //   return regex.hasMatch(phoneNumber);
  // }

  Future<void> verifyOtp(String otpCode, BuildContext context) async {
    if (_pendingUserId == null || _pendingUserData == null) {
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.fail,
        label: 'لم يتم العثور على تحقق قيد الانتظار. يرجى المحاولة مرة أخرى.',
      );
      emit(SignupFailure('No pending verification'));
      return;
    }

    emit(SignupLoading());
    try {
      // 1. Verify OTP
      final response = await _supabase
          .from('pending_users')
          .select()
          .eq('user_id', _pendingUserId!)
          .eq('otp_code', otpCode)
          .single();

      final expiryTime = DateTime.parse(response['expires_at']);
      if (expiryTime.isBefore(DateTime.now())) {
        throw Exception('انتهت صلاحية رمز التحقق');
      }

      // 2. Insert user into appropriate table
      final userType = _pendingUserData!['user_type'];
      switch (userType) {
        case 'client':
          await _insertClient();
          break;
        case 'facility':
          await _insertFacility();
          break;
        case 'delivery':
          await _insertDelivery();
          break;
        default:
          throw Exception('نوع المستخدم غير صحيح');
      }

      // 3. Clean up pending users
      await _supabase
          .from('pending_users')
          .delete()
          .eq('user_id', _pendingUserId!);

      emit(SignupVerificationSuccess(
        userType: userType,
      ));
      if (!context.mounted) return;
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.success,
        label: 'تم التحقق من الحساب بنجاح!',
      );
    } on PostgrestException catch (e) {
      String errorMessage;
      if (e.code == '42501') {
        errorMessage = 'فشل التحقق من الرمز. يرجى المحاولة مرة أخرى.';
      } else if (e.code == '42703') {
        errorMessage = 'انتهت صلاحية الجلسة. يرجى طلب رمز جديد.';
      } else {
        errorMessage = 'فشل التحقق. خطأ: ${e.message}';
      }

      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.fail,
        label: errorMessage,
      );
      emit(SignupFailure(e.message));
    } catch (e) {
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.fail,
        label: 'حدث خطأ غير متوقع أثناء التحقق.',
      );
      emit(SignupFailure(e.toString()));
    }
  }

  Future<void> resendOtp(BuildContext context) async {
    if (_pendingUserId == null || _pendingUserData == null) {
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.fail,
        label: 'لا يوجد تحقق قيد الانتظار',
      );
      emit(SignupFailure('No pending verification'));
      return;
    }

    emit(SignupLoading());
    try {
      final otpCode = _generateOtp();
      await _supabase.from('pending_users').update({
        'otp_code': otpCode,
        'expires_at':
            DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      }).eq('user_id', _pendingUserId!);

      await _sendOtpNotification(otpCode, _pendingUserData!['phone_number']);

      emit(SignupOtpResent(phoneNumber: _pendingUserData!['phone_number']));
      if (!context.mounted) return;
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.success,
        label: 'تم إرسال رمز تحقق جديد إلى رقم هاتفك.',
      );
    } catch (e) {
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.fail,
        label: 'فشل إعادة إرسال الرمز. يرجى المحاولة مرة أخرى.',
      );
      emit(SignupFailure(e.toString()));
    }
  }

  void _handleAuthError(AuthException e, BuildContext context) {
    String errorMessage;
    SnackBarType snackBarType;

    switch (e.message) {
      case 'User already registered':
        errorMessage = 'البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول.';
        snackBarType = SnackBarType.fail;
        break;
      case 'Invalid email address':
        errorMessage = 'الرجاء إدخال بريد إلكتروني صالح.';
        snackBarType = SnackBarType.fail;
        break;
      case 'Password should be at least 6 characters':
        errorMessage = 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';
        snackBarType = SnackBarType.fail;
        break;
      case 'Email rate limit exceeded':
        errorMessage = 'عدد محاولات كثيرة. يرجى المحاولة مرة أخرى لاحقًا.';
        snackBarType = SnackBarType.alert;
        break;
      case 'Email link is invalid or has expired':
        errorMessage = 'رابط التحقق غير صالح أو منتهي الصلاحية.';
        snackBarType = SnackBarType.fail;
        break;
      case 'Invalid login credentials':
        errorMessage = 'بريد إلكتروني أو كلمة مرور غير صحيحة.';
        snackBarType = SnackBarType.fail;
        break;
      case 'Too many requests':
        errorMessage =
            'عدد محاولات كثيرة. يرجى الانتظار قبل المحاولة مرة أخرى.';
        snackBarType = SnackBarType.alert;
        break;
      case 'Network request failed':
        errorMessage = 'خطأ في الشبكة. يرجى التحقق من اتصالك.';
        snackBarType = SnackBarType.fail;
        break;
      default:
        errorMessage = 'حدث خطأ أثناء التسجيل. يرجى المحاولة مرة أخرى.';
        snackBarType = SnackBarType.fail;
    }

    CustomSnackbar(
      context: context,
      snackBarType: snackBarType,
      label: errorMessage,
    );
  }

  void _handleGenericError(dynamic e, BuildContext context) {
    CustomSnackbar(
      context: context,
      snackBarType: SnackBarType.fail,
      label: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
    );
  }

  Future<void> _insertClient() async {
    await _supabase.from('clients').insert({
      'id': _pendingUserId,
      'email': _pendingUserData!['email'],
      'user_name': _pendingUserData!['user_name'],
      'phone_number': _pendingUserData!['phone_number'],
      'directorate': _pendingUserData!['directorate'],
    });
  }

  Future<void> _insertFacility() async {
    await _supabase.from('facilities').insert({
      'id': _pendingUserId,
      'email': _pendingUserData!['email'],
      'user_name': _pendingUserData!['user_name'],
      'phone_number': _pendingUserData!['phone_number'],
      'directorate': _pendingUserData!['directorate'],
      'facility_name': _pendingUserData!['facility_name'],
      'facility_category': _pendingUserData!['facility_category'],
    });
  }

  Future<void> _insertDelivery() async {
    await _supabase.from('delivery').insert({
      'id': _pendingUserId,
      'email': _pendingUserData!['email'],
      'user_name': _pendingUserData!['user_name'],
      'phone_number': _pendingUserData!['phone_number'],
      'directorate': _pendingUserData!['directorate'],
      'delivery_license': _pendingUserData!['delivery_license'],
    });
  }

  String _generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> _sendOtpNotification(String otpCode, String phoneNumber) async {
    try {
      await NotificationServices().showNotification(
        title: 'تحقق من الرمز',
        body: 'رمز التحقق الخاص بك هو $otpCode. ستنتهي صلاحيته خلال 15 دقيقة.',
      );
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> close() {
    _pendingUserId = null;
    _pendingUserData = null;
    return super.close();
  }
}
