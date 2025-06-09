// lib/features/delivery/orders/data/repositories/delivery_orders_repository.dart
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryOrdersRepository {
  final SupabaseClient supabaseClient;

  DeliveryOrdersRepository(this.supabaseClient);

  Future<List<Order>> getAssignedOrders(String deliveryId) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select('*')
          .eq('delivery_id', deliveryId)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      return response.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<List<Order>> getAvailableOrders() async {
    try {
      String? userId = await SharedPreferencesService.getUserId();
      final response = await supabaseClient
          .from('orders')
          .select('*')
          .eq('order_status', 'pending')
          .eq('delivery_id', userId!)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      return response.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Failed to fetch available orders: $e');
    }
  }

  Stream<List<Order>> watchAssignedOrders(String deliveryId) {
    return supabaseClient
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('delivery_id', deliveryId)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map<Order>((order) => Order.fromJson(order)).toList());
  }

  Future<void> acceptOrder(String orderId, String deliveryId) async {
    try {
      await supabaseClient.from('orders').update({
        'delivery_id': deliveryId,
        'order_status': 'shipped',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await supabaseClient.from('orders').update({
        'order_status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
