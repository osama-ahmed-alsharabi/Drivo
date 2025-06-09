// lib/features/delivery/orders/presentation/cubit/delivery_orders_state.dart
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class DeliveryOrdersState extends Equatable {
  const DeliveryOrdersState();

  @override
  List<Object> get props => [];
}

class DeliveryOrdersInitial extends DeliveryOrdersState {}

class DeliveryOrdersLoading extends DeliveryOrdersState {}

class DeliveryOrdersLoaded extends DeliveryOrdersState {
  final List<Order> assignedOrders;
  final List<Order> availableOrders;

  const DeliveryOrdersLoaded({
    required this.assignedOrders,
    required this.availableOrders,
  });

  @override
  List<Object> get props => [assignedOrders, availableOrders];
}

class DeliveryOrdersError extends DeliveryOrdersState {
  final String message;

  const DeliveryOrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderStatusUpdated extends DeliveryOrdersState {
  final Order order;

  const OrderStatusUpdated(this.order);

  @override
  List<Object> get props => [order];
}
