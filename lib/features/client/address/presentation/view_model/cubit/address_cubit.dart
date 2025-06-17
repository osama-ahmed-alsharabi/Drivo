import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final DatabaseService databaseService;

  AddressCubit({required this.databaseService}) : super(AddressInitial());

  Future<void> loadAddresses() async {
    emit(AddressLoading());
    try {
      final addresses = await databaseService.getAddresses();
      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: 'Failed to load addresses: ${e.toString()}'));
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      emit(AddressLoading());

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(AddressError(message: 'Location services are disabled'));
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(AddressError(message: 'Location permissions are denied'));
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(AddressError(
            message: 'Location permissions are permanently denied'));
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final LatLng location = LatLng(position.latitude, position.longitude);
      final address = _formatAddress(placemarks.first);

      emit(LocationSelected(location, address));
      return location;
    } catch (e) {
      emit(AddressError(message: 'Failed to get location: ${e.toString()}'));
      return null;
    }
  }

  Future<void> getAddressFromPosition(LatLng position) async {
    try {
      emit(AddressLoading());
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      emit(LocationSelected(position, _formatAddress(placemarks.first)));
    } catch (e) {
      emit(AddressError(message: 'Failed to get address from position'));
    }
  }

  String _formatAddress(Placemark placemark) {
    return [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].where((part) => part?.isNotEmpty ?? false).join(', ');
  }

  Future<void> saveAddress({
    required String title,
    required String address,
    required LatLng position,
    String additionalInfo = '',
  }) async {
    try {
      emit(AddressSaving());
      await databaseService.insertAddress({
        'title': title,
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'additionalInfo': additionalInfo,
        'isDefault': 0,
      });
      await loadAddresses();
    } catch (e) {
      emit(AddressError(message: 'Failed to save address: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> updateAddress(Map<String, dynamic> address) async {
    try {
      emit(AddressSaving());
      await databaseService.updateAddress(address);
      await loadAddresses();
    } catch (e) {
      emit(AddressError(message: 'Failed to update address: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> setDefaultAddress(int id) async {
    try {
      emit(AddressLoading());
      await databaseService.setDefaultAddress(id);
      await loadAddresses();
    } catch (e) {
      emit(AddressError(
          message: 'Failed to set default address: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      emit(AddressLoading());
      await databaseService.deleteAddress(id);
      await loadAddresses();
    } catch (e) {
      emit(AddressError(message: 'Failed to delete address: ${e.toString()}'));
      rethrow;
    }
  }
}
