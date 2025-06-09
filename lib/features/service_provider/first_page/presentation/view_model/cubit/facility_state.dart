part of 'facility_cubit.dart';

abstract class FacilityState extends Equatable {
  const FacilityState();

  @override
  List<Object> get props => [];
}

class FacilityInitial extends FacilityState {}

class FacilitySaving extends FacilityState {}

class FacilitySaved extends FacilityState {}

class FacilityError extends FacilityState {
  final String message;

  const FacilityError(this.message);

  @override
  List<Object> get props => [message];
}
