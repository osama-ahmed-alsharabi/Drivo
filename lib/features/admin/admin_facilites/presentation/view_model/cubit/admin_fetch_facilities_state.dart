// features/admin/admin_facilites/presentation/view_model/cubit/admin_fetch_facilities_state.dart

import 'package:equatable/equatable.dart';

abstract class AdminFetchFacilitiesState extends Equatable {
  const AdminFetchFacilitiesState();

  @override
  List<Object> get props => [];
}

// In your admin_fetch_facilities_state.dart
class RestaurantRatingUpdated extends AdminFetchFacilitiesState {
  final Map<String, dynamic> updatedRestaurant;

  const RestaurantRatingUpdated({required this.updatedRestaurant});

  @override
  List<Object> get props => [updatedRestaurant];
}

class AdminFetchFacilitiesInitail extends AdminFetchFacilitiesState {}

class AdminFetchFacilitiesLoading extends AdminFetchFacilitiesState {}

class AdminFetchFacilitiesLoaded extends AdminFetchFacilitiesState {
  final List<Map<String, dynamic>> restaurants;
  const AdminFetchFacilitiesLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

class AdminFetchFacilitiesError extends AdminFetchFacilitiesState {
  final String message;
  const AdminFetchFacilitiesError({required this.message});

  @override
  List<Object> get props => [message];
}

class RestaurantListEmpty extends AdminFetchFacilitiesState {}

class RestaurantStatusUpdated extends AdminFetchFacilitiesState {
  final Map<String, dynamic> updatedRestaurant;
  const RestaurantStatusUpdated({required this.updatedRestaurant});

  @override
  List<Object> get props => [updatedRestaurant];
}
