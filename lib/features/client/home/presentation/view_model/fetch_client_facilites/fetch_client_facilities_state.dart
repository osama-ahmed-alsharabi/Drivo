part of 'fetch_client_facilities_cubit.dart';

sealed class FetchClientFacilitiesState extends Equatable {
  const FetchClientFacilitiesState();

  @override
  List<Object> get props => [];
}

final class FetchClientFacilitiesInitial extends FetchClientFacilitiesState {}

final class FetchClientFacilitiesSuccess extends FetchClientFacilitiesState {
  final List<FacilityModel> facilityModel;

  const FetchClientFacilitiesSuccess({required this.facilityModel});
}

final class FetchClientFacilitiesLoading extends FetchClientFacilitiesState {}

final class FetchClientFacilitiesFaulier extends FetchClientFacilitiesState {}
