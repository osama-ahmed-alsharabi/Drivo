// features/admin/orders/presentation/view_model/cubit/admin_orders_cubit.dart
import 'dart:math';

import 'package:drivo_app/features/admin/admin_order/presentation/view_model/cubit/admin_orders_state.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Order> _allOrders = [];

  AdminOrdersCubit() : super(AdminOrdersInitial());

  void filterOrders(String query) {
    if (query.isEmpty) {
      emit(AdminOrdersLoaded(orders: _allOrders));
      return;
    }

    final filtered = _allOrders.where((order) {
      final orderNumber = order.orderNumber.toLowerCase();
      final customerName = order.deliveryAddress.title.toLowerCase();
      final searchLower = query.toLowerCase();

      return orderNumber.contains(searchLower) ||
          customerName.contains(searchLower);
    }).toList();

    emit(filtered.isEmpty
        ? OrdersListEmpty()
        : AdminOrdersLoaded(orders: filtered));
  }

  Future<void> fetchOrders() async {
    emit(AdminOrdersLoading());
    try {
      final exchangeResponse = await supabaseClient
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final exchangeRate = (exchangeResponse['rate'] as num).toDouble();

      final response = await supabaseClient
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      _allOrders =
          (response as List).map((json) => Order.fromJson(json)).toList();

      if (_allOrders.isEmpty) {
        emit(OrdersListEmpty());
      } else {
        emit(AdminOrdersLoaded(orders: _allOrders, exchange: exchangeRate));
      }
    } catch (e) {
      emit(AdminOrdersError(message: e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // Update in Supabase
      await supabaseClient
          .from('orders')
          .update({'order_status': newStatus.value}).eq('id', orderId);

      // Update local state
      final updatedIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (updatedIndex != -1) {
        final updatedOrder =
            _allOrders[updatedIndex].copyWith(status: newStatus);
        _allOrders[updatedIndex] = updatedOrder;
        emit(OrderStatusUpdated(updatedOrder: updatedOrder));
        emit(AdminOrdersLoaded(orders: _allOrders));
      }
    } catch (e) {
      emit(
          AdminOrdersError(message: 'Failed to update order: ${e.toString()}'));
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      emit(AdminOrdersLoading());

      // 1. Get the order details
      final orderResponse = await supabaseClient
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .single();

      final order = Order.fromJson(orderResponse);
      final restaurantId = order.items.first.restaurantId;

      // 2. Get restaurant location
      final restaurantLocation = await supabaseClient
          .from('facilities')
          .select('latitude, longitude')
          .eq('id', restaurantId)
          .single();

      final restaurantLat = restaurantLocation['latitude'] as double;
      final restaurantLon = restaurantLocation['longitude'] as double;

      // 3. Get all available deliveries (status = 'available')
      final deliveriesResponse = await supabaseClient
          .from('delivery')
          .select('*')
          .eq('is_active', true);

      if (deliveriesResponse.isEmpty) {
        emit(const AdminOrdersError(
            message: 'لا يوجد مندوبين توصيل متاحين حالياً'));
        return;
      }

      // 4. Find nearest delivery person
      String? nearestDeliveryId;
      double minDistance = double.infinity;

      for (final delivery in deliveriesResponse) {
        if (delivery['latitude'] != null && delivery['longitude'] != null) {
          final deliveryLat = delivery['latitude'] as double;
          final deliveryLon = delivery['longitude'] as double;

          final distance = _calculateDistance(
            restaurantLat,
            restaurantLon,
            deliveryLat,
            deliveryLon,
          );

          if (distance < minDistance) {
            minDistance = distance;
            nearestDeliveryId = delivery['id'] as String;
          }
        }
      }

      if (nearestDeliveryId == null) {
        emit(const AdminOrdersError(
            message: 'تعذر العثور على مندوب توصيل قريب'));
        return;
      }

      // 5. Update order with delivery info
      await supabaseClient.from('orders').update({
        'delivery_id': nearestDeliveryId,
        'delivery_status': 'pending',
        'order_status': 'shipped',
      }).eq('id', orderId);

      // 6. Update delivery person status to 'busy'
      await supabaseClient.from('delivery').update({
        'status': 'busy',
      }).eq('id', nearestDeliveryId);

      // 7. Refresh orders list
      await fetchOrders();

      emit(OrderStatusUpdated(
        updatedOrder: order.copyWith(
          status: OrderStatus.confirmed,
          deliveryId: nearestDeliveryId,
        ),
      ));
    } catch (e) {
      emit(AdminOrdersError(message: 'فشل تأكيد الطلب: ${e.toString()}'));
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
