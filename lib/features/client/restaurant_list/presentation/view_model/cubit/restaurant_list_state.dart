part of 'restaurant_list_cubit.dart';

abstract class RestaurantListState extends Equatable {
  const RestaurantListState();

  @override
  List<Object> get props => [];
}

class RestaurantListInitial extends RestaurantListState {}

class RestaurantListLoading extends RestaurantListState {}

class RestaurantListEmpty extends RestaurantListState {}

class RestaurantListLoaded extends RestaurantListState {
  final List<Map<String, dynamic>> restaurants;

  const RestaurantListLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

class RestaurantListError extends RestaurantListState {
  final String message;

  const RestaurantListError({required this.message});

  @override
  List<Object> get props => [message];
}
