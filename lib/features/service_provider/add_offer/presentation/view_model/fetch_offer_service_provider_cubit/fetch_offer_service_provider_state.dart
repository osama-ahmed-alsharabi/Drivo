// fetch_offer_service_provider_state.dart

part of 'fetch_offer_service_provider_cubit.dart';

abstract class FetchOfferServiceProviderState extends Equatable {
  const FetchOfferServiceProviderState();

  @override
  List<Object> get props => [];
}

class FetchOfferServiceProviderInitial extends FetchOfferServiceProviderState {}

class FetchOfferServiceProviderLoading extends FetchOfferServiceProviderState {}

class FetchOfferServiceProviderSuccessfully
    extends FetchOfferServiceProviderState {}

class FetchOfferServiceProviderFaulid extends FetchOfferServiceProviderState {
  final String errorMessage;
  const FetchOfferServiceProviderFaulid({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class FetchOfferServiceProviderDeletedSuccessfully
    extends FetchOfferServiceProviderState {}

class FetchOfferServiceProviderDeletedFauild
    extends FetchOfferServiceProviderState {
  final String errorMessage;
  const FetchOfferServiceProviderDeletedFauild({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
