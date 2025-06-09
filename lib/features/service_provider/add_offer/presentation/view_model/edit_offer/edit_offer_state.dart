// features/service_provider/edit_offer/presentation/view_model/edit_offer_state.dart

part of 'edit_offer_cubit.dart';

abstract class EditOfferState extends Equatable {
  const EditOfferState();

  @override
  List<Object> get props => [];
}

class EditOfferInitial extends EditOfferState {}

class EditOfferLoading extends EditOfferState {}

class EditOfferSuccess extends EditOfferState {
  final String message;
  const EditOfferSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EditOfferFailure extends EditOfferState {
  final String error;
  const EditOfferFailure(this.error);

  @override
  List<Object> get props => [error];
}
