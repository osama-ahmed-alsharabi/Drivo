import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'facility_state.dart';

class FacilityCubit extends Cubit<FacilityState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  FacilityCubit() : super(FacilityInitial());
  bool hasLoaded = false;
  Future<String> uploadImage(File image, String bucketName) async {
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

  Future<void> saveFacilityInfo({
    required String userName,
    required String directorate,
    required String facilityCategory,
    required String userId,
    required String facilityName,
    required String description,
    required String phoneNumber,
    required String email,
    required String address,
    required double latitude,
    required double longitude,
    required File logoImage,
    File? coverImage,
    required Map<String, TimeOfDay> businessHours,
    required Map<String, TimeOfDay> closingHours,
  }) async {
    if (hasLoaded) {
      emit(FacilitySaving());

      try {
        // Upload images
        final logoUrl = await uploadImage(logoImage, 'facility-logos');
        String? coverImageUrl;

        if (coverImage != null) {
          coverImageUrl = await uploadImage(coverImage, 'facility-covers');
        }

        // Format business hours
        // Format business hours with AM/PM
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
        });

        emit(FacilitySaved());
      } catch (e) {
        log(e.toString());
        emit(FacilityError(e.toString()));
      }
    }
  }

  String _formatTimeWithAmPm(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
