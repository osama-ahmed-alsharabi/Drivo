part of 'edit_service_provider_profile_cubit.dart';

abstract class EditServiceProviderProfileState extends Equatable {
  const EditServiceProviderProfileState();

  @override
  List<Object> get props => [];
}

class EditServiceProviderProfileInitial
    extends EditServiceProviderProfileState {}

class EditServiceProviderProfileLoading
    extends EditServiceProviderProfileState {}

class EditServiceProviderProfileSuccess
    extends EditServiceProviderProfileState {}

class EditServiceProviderProfileError extends EditServiceProviderProfileState {
  final String message;

  const EditServiceProviderProfileError(this.message);

  @override
  List<Object> get props => [message];
}
