// features/admin/orders/presentation/view_model/cubit/admin_orders_state.dart

import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class AdminOrdersState extends Equatable {
  const AdminOrdersState();

  @override
  List<Object> get props => [];
}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<Order> orders;
  final double? exchange;
  const AdminOrdersLoaded({
    required this.orders,
    this.exchange,
  });

  @override
  List<Object> get props => [orders];
}

class AdminOrdersError extends AdminOrdersState {
  final String message;
  const AdminOrdersError({required this.message});

  @override
  List<Object> get props => [message];
}

class OrdersListEmpty extends AdminOrdersState {}

class OrderStatusUpdated extends AdminOrdersState {
  final Order updatedOrder;
  const OrderStatusUpdated({required this.updatedOrder});

  @override
  List<Object> get props => [updatedOrder];
}
