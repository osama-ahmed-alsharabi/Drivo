part of 'adding_offer_service_provider_cubit.dart';

abstract class AddingOfferServiceProviderState extends Equatable {
  const AddingOfferServiceProviderState();

  @override
  List<Object> get props => [];
}

class AddingOfferServiceProviderInitial
    extends AddingOfferServiceProviderState {}

class AddingOfferServiceProviderLoading
    extends AddingOfferServiceProviderState {}

class AddingOfferServiceProviderSuccess
    extends AddingOfferServiceProviderState {
  final String message;
  const AddingOfferServiceProviderSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AddingOfferServiceProviderFailure
    extends AddingOfferServiceProviderState {
  final String error;
  const AddingOfferServiceProviderFailure(this.error);

  @override
  List<Object> get props => [error];
}
