// lib/features/delivery/location/services/location_service.dart
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  LocationService();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateDeliveryLocation({
    required String deliveryId,
    required double lat,
    required double lng,
    String? address,
  }) async {
    String? userName = await SharedPreferencesService.getUserName();
    await supabaseClient.from('delivery').upsert({
      'id': deliveryId,
      "user_name": userName,
      'latitude': lat,
      'longitude': lng,
      'address': address,
      // 'last_location_update': DateTime.now().toIso8601String(),
    });
  }
}
