// lib/features/delivery/orders/presentation/cubit/delivery_orders_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:drivo_app/features/delivery/delivery_order_screen/presentation/view_model/delivery_orders_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'delivery_orders_state.dart';

class DeliveryOrdersCubit extends Cubit<DeliveryOrdersState> {
  final DeliveryOrdersRepository _repository;
  StreamSubscription? _ordersSubscription;

  DeliveryOrdersCubit(this._repository) : super(DeliveryOrdersInitial());

  Future<void> loadOrders(String deliveryId) async {
    emit(DeliveryOrdersLoading());
    try {
      final assignedOrders = await _repository.getAssignedOrders(deliveryId);
      final availableOrders = await _repository.getAvailableOrders();
      emit(DeliveryOrdersLoaded(
        assignedOrders: assignedOrders,
        availableOrders: availableOrders,
      ));
    } catch (e) {
      emit(DeliveryOrdersError(e.toString()));
    }
  }

  Future<void> subscribeToOrdersUpdates(String deliveryId) async {
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('delivery_id', deliveryId)
        .listen((_) => loadOrders(deliveryId));
  }

  Future<void> acceptOrder(String orderId, String deliveryId) async {
    try {
      await _repository.acceptOrder(orderId, deliveryId);
      await loadOrders(deliveryId);
    } catch (e) {
      emit(DeliveryOrdersError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      final currentState = state;
      if (currentState is DeliveryOrdersLoaded) {
        final updatedOrder = currentState.assignedOrders
            .firstWhere((order) => order.id == orderId)
            .copyWith(status: status);
        emit(OrderStatusUpdated(updatedOrder));
        await loadOrders(updatedOrder.deliveryId!);
      }
    } catch (e) {
      emit(DeliveryOrdersError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
