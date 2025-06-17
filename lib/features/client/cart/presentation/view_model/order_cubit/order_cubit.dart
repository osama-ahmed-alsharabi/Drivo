import 'dart:math';
import 'package:drivo_app/features/client/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  OrderCubit() : super(OrderInitial());

  double _toRadians(double degrees) => degrees * pi / 180;

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
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

  Future<void> submitOrder({
    required List<CartItem> cartItems,
    required Map<String, dynamic> address,
    required String userId,
  }) async {
    try {
      emit(OrderSubmitting());

      // Get client data including points
      final clientResponse = await _supabase
          .from('clients')
          .select('points')
          .eq('id', userId)
          .single();

      int currentPoints = clientResponse['points'] ?? 0;
      bool isFreeDelivery = currentPoints >= 5;
      int newPoints = isFreeDelivery ? 0 : currentPoints + 1;

      // Get exchange rate
      final exchangeResponse = await _supabase
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final exchangeRate = (exchangeResponse['rate'] as num).toDouble();

      // Get latest delivery fee per km
      final deliveryFeeResponse = await _supabase
          .from('delivery_fee')
          .select('fee_per_km')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final deliveryFeePerKm =
          (deliveryFeeResponse['fee_per_km'] as num).toDouble();

      // Group items by restaurant
      final restaurantGroups = <String, List<CartItem>>{};
      for (final item in cartItems) {
        final restaurantId = item.product.restaurantId;
        restaurantGroups.putIfAbsent(restaurantId, () => []).add(item);
      }

      // Get all restaurant locations
      final restaurantLocations = <String, Map<String, double>>{};
      for (final restaurantId in restaurantGroups.keys) {
        final facility = await _supabase
            .from('facilities')
            .select('latitude, longitude')
            .eq('id', restaurantId)
            .single();

        restaurantLocations[restaurantId] = {
          'latitude': (facility['latitude'] as num).toDouble(),
          'longitude': (facility['longitude'] as num).toDouble(),
        };
      }

      // Calculate delivery fees for each restaurant
      double totalDeliveryFee = 0.0;
      final clientLat = address['latitude'] as double;
      final clientLon = address['longitude'] as double;

      for (final restaurantId in restaurantLocations.keys) {
        final location = restaurantLocations[restaurantId]!;
        final distance = _calculateDistance(
          clientLat,
          clientLon,
          location['latitude']!,
          location['longitude']!,
        );

        totalDeliveryFee += distance * deliveryFeePerKm;
      }

      // Calculate order totals
      final subtotal = cartItems.fold(
          0.0, (sum, item) => sum + (item.product.price * item.quantity));
      const discount = 0.0;
      final total =
          subtotal + (isFreeDelivery ? 0 : totalDeliveryFee) - discount;

      // Prepare order data
      final orderData = {
        'user_id': userId,
        'restaurant_ids': restaurantGroups.keys.toList(),
        'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'items': cartItems
            .map((item) => {
                  'product_id': item.product.id,
                  'name': item.product.name,
                  'quantity': item.quantity,
                  'price': item.product.price,
                  'total': item.product.price * item.quantity,
                  'restaurant_id': item.product.restaurantId,
                })
            .toList(),
        'subtotal': subtotal,
        'delivery_fee': isFreeDelivery ? 0.0 : totalDeliveryFee,
        'discount': discount,
        'total_amount': total,
        'delivery_address': address,
        'payment_method': 'cash_on_delivery',
        'payment_status': 'pending',
        'order_status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      if (isFreeDelivery) {
        emit(const OrderFree(isFree: true));
      }

      await _supabase.from('orders').insert(orderData);
      await _supabase
          .from('clients')
          .update({'points': newPoints}).eq('id', userId);

      emit(OrderSuccess(
        orderData,
        exchangeRate,
        isFreeDelivery: isFreeDelivery,
      ));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}
