part of 'admin_edit_offer_cubit_cubit.dart';

sealed class AdminEditOfferCubitState extends Equatable {
  const AdminEditOfferCubitState();

  @override
  List<Object> get props => [];
}

final class AdminEditOfferCubitInitial extends AdminEditOfferCubitState {}

final class AdminEditOfferCubitLoading extends AdminEditOfferCubitState {}

final class AdminEditOfferCubitSuccess extends AdminEditOfferCubitState {}

final class AdminEditOfferCubitFauler extends AdminEditOfferCubitState {}
