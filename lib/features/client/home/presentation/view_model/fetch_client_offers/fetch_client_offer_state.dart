part of 'fetch_client_offer_cubit.dart';

sealed class FetchClientOfferState extends Equatable {
  const FetchClientOfferState();

  @override
  List<Object> get props => [];
}

final class FetchClientOfferInitial extends FetchClientOfferState {}

final class FetchClientOfferSuccess extends FetchClientOfferState {
  final List<OfferModel> offerModel;

  const FetchClientOfferSuccess({required this.offerModel});
}

final class FetchClientOfferLoading extends FetchClientOfferState {}

final class FetchClientOfferFaulier extends FetchClientOfferState {
  final String errorMessage;

  const FetchClientOfferFaulier({required this.errorMessage});
}
