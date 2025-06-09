import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'edit_service_provider_profile_state.dart';

class EditServiceProviderProfileCubit
    extends Cubit<EditServiceProviderProfileState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  EditServiceProviderProfileCubit()
      : super(EditServiceProviderProfileInitial());

  Future<String> _uploadImage(File image, String bucketName) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      await supabaseClient.storage.from(bucketName).upload(filePath, image);
      return supabaseClient.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String userName,
    required String directorate,
    required String facilityCategory,
    required String facilityName,
    required String description,
    required String phoneNumber,
    required String email,
    required String address,
    required double latitude,
    required double longitude,
    required Map<String, TimeOfDay> businessHours,
    required Map<String, TimeOfDay> closingHours,
    File? logoImage,
    File? coverImage,
    required String? currentLogoUrl,
    required String? currentCoverUrl,
  }) async {
    emit(EditServiceProviderProfileLoading());

    try {
      String? logoUrl = currentLogoUrl;
      String? coverImageUrl = currentCoverUrl;

      // Upload new images if provided
      if (logoImage != null) {
        logoUrl = await _uploadImage(logoImage, 'facility-logos');
      }
      if (coverImage != null) {
        coverImageUrl = await _uploadImage(coverImage, 'facility-covers');
      }

      // Format business hours
      final openingSunThu =
          _formatTimeWithAmPm(businessHours['sundayToThursday']!);
      final closingSunThu =
          _formatTimeWithAmPm(closingHours['sundayToThursday']!);
      final openingFri = _formatTimeWithAmPm(businessHours['friday']!);
      final closingFri = _formatTimeWithAmPm(closingHours['friday']!);
      final openingSat = _formatTimeWithAmPm(businessHours['saturday']!);
      final closingSat = _formatTimeWithAmPm(closingHours['saturday']!);

      // Update facility data
      await supabaseClient.from('facilities').upsert({
        'id': userId,
        'user_name': userName,
        "directorate": directorate,
        "facility_category": facilityCategory,
        "is_active": true,
        'facility_name': facilityName,
        'description': description,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'cover_image_url': coverImageUrl,
        'logo_url': logoUrl,
        'opening_hours_sun_thu': openingSunThu,
        'closing_hours_sun_thu': closingSunThu,
        'opening_hours_fri': openingFri,
        'closing_hours_fri': closingFri,
        'opening_hours_sat': openingSat,
        'closing_hours_sat': closingSat,
        'updated_at': DateTime.now().toIso8601String(),
      });

      emit(EditServiceProviderProfileSuccess());
    } catch (e) {
      emit(EditServiceProviderProfileError(e.toString()));
    }
  }

  String _formatTimeWithAmPm(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
