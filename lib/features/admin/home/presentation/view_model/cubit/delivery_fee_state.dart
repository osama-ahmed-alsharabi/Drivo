// features/admin/delivery_fee/presentation/view_model/cubit/delivery_fee_state.dart
part of 'delivery_fee_cubit.dart';

abstract class DeliveryFeeState extends Equatable {
  const DeliveryFeeState();

  @override
  List<Object> get props => [];
}

class DeliveryFeeInitial extends DeliveryFeeState {}

class DeliveryFeeLoading extends DeliveryFeeState {}

class DeliveryFeeLoaded extends DeliveryFeeState {
  final double feePerKm;

  const DeliveryFeeLoaded({required this.feePerKm});

  @override
  List<Object> get props => [feePerKm];
}

class DeliveryFeeError extends DeliveryFeeState {
  final String message;

  const DeliveryFeeError({required this.message});

  @override
  List<Object> get props => [message];
}
