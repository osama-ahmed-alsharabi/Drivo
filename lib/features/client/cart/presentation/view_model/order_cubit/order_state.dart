part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderSubmitting extends OrderState {}

class OrderSuccess extends OrderState {
  final Map<String, dynamic> orderData;
  final double exchangeRate;
  final bool isFreeDelivery;

  const OrderSuccess(this.orderData, this.exchangeRate,
      {this.isFreeDelivery = false});

  @override
  List<Object> get props => [orderData, exchangeRate, isFreeDelivery];
}

class OrderFree extends OrderState {
  final bool isFree;

  const OrderFree({required this.isFree});

  @override
  List<Object> get props => [isFree];
}

class OrderFailure extends OrderState {
  final String error;

  const OrderFailure(this.error);

  @override
  List<Object> get props => [error];
}
