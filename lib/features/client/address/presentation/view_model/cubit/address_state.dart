// import 'package:google_maps_flutter/google_maps_flutter.dart';

// abstract class AddressState {}

// class AddressInitial extends AddressState {}

// class AddressLoading extends AddressState {}

// class AddressLoaded extends AddressState {
//   final List<Map<String, dynamic>> addresses;

//   AddressLoaded({required this.addresses});
// }

// class AddressSaving extends AddressState {}

// class LocationSelected extends AddressState {
//   final LatLng position;
//   final String address;

//   LocationSelected(this.position, this.address);
// }

// class AddressError extends AddressState {
//   final String message;

//   AddressError({required this.message});
// }

import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Map<String, dynamic>> addresses;

  AddressLoaded({required this.addresses});
}

class LocationSelected extends AddressState {
  final LatLng position;
  final String address;

  LocationSelected(this.position, this.address);
}

class AddressSaving extends AddressState {}

class AddressError extends AddressState {
  final String message;

  AddressError({required this.message});
}
