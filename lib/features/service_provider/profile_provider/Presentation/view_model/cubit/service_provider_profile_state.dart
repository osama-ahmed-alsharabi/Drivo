// service_provider_profile_state.dart
part of 'service_provider_profile_cubit.dart';

abstract class ServiceProviderProfileState extends Equatable {
  const ServiceProviderProfileState();

  @override
  List<Object> get props => [];
}

class ServiceProviderProfileInitial extends ServiceProviderProfileState {}

class ServiceProviderProfileLoading extends ServiceProviderProfileState {}

class ServiceProviderProfileLoaded extends ServiceProviderProfileState {
  final Map<String, dynamic> profileData;

  const ServiceProviderProfileLoaded(this.profileData);

  @override
  List<Object> get props => [profileData];
}

class ServiceProviderProfileError extends ServiceProviderProfileState {
  final String message;

  const ServiceProviderProfileError(this.message);

  @override
  List<Object> get props => [message];
}
