part of 'admin_fetch_offers_cubit.dart';

sealed class AdminFetchOffersState extends Equatable {
  const AdminFetchOffersState();

  @override
  List<Object> get props => [];
}

final class AdminFetchOffersInitial extends AdminFetchOffersState {}

final class AdminFetchOffersSuccess extends AdminFetchOffersState {}

final class AdminFetchOffersLoading extends AdminFetchOffersState {}

final class AdminFetchOffersFauiler extends AdminFetchOffersState {
  final String errorMessage;

  const AdminFetchOffersFauiler({required this.errorMessage});
}

final class AdminFetchOfferDeletedSccess extends AdminFetchOffersState {}

final class AdminFetchOffersDeletedFauiler extends AdminFetchOffersState {
  final String errorMessage;

  const AdminFetchOffersDeletedFauiler({required this.errorMessage});
}
