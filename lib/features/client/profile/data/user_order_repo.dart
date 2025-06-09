// lib/features/client/orders/data/repositories/orders_repository.dart
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOrdersRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Order>> getUserOrders(String userId) async {
    final response = await _supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Order.fromJson(json)).toList();
  }
}
