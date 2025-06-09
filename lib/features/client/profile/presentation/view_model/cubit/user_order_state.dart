// lib/features/client/orders/presentation/cubit/orders_state.dart

import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserOrdersState extends Equatable {
  const UserOrdersState();

  @override
  List<Object> get props => [];
}

class UserOrdersInitial extends UserOrdersState {}

class UserOrdersLoading extends UserOrdersState {}

class UserOrdersLoaded extends UserOrdersState {
  final List<Order> orders;

  const UserOrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class UserOrdersError extends UserOrdersState {
  final String message;

  const UserOrdersError(this.message);

  @override
  List<Object> get props => [message];
}
