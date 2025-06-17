// lib/features/restaurant/report/presentation/cubit/restaurant_report_cubit.dart
import 'dart:async';
import 'dart:developer';
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/restaurant_report_view.dart';
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/view_model/cubit/restaurant_report_state.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantReportCubit extends Cubit<RestaurantReportState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final String restaurantId;
  DateTime? startDate;
  DateTime? endDate;

  RestaurantReportCubit({required this.restaurantId})
      : super(RestaurantReportInitial()) {
    final now = DateTime.now();
    startDate = now.subtract(const Duration(days: 7));
    endDate = now;
  }

  Future<void> fetchReport() async {
    emit(RestaurantReportLoading());
    try {
      final report = await _generateReport();
      emit(RestaurantReportLoaded(
        report,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      log(e.toString());
      emit(RestaurantReportError(e.toString()));
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    fetchReport();
  }

  Future<RestaurantReport> _generateReport() async {
    if (startDate == null || endDate == null) {
      throw Exception('Date range not set');
    }

    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end =
        DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);

    final ordersResponse = await supabaseClient
        .from('orders')
        .select()
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .filter('items', 'cs', '[{"restaurant_id": "$restaurantId"}]');
    final orders = ordersResponse.map((json) => Order.fromJson(json)).toList();
    final totalOrders = orders.length;

    double totalRevenue = orders
        .where((order) =>
            order.status != OrderStatus.cancelled &&
            order.status != OrderStatus.refunded)
        .fold(0, (sum, order) => sum + order.totalAmount);

    // Group orders by status
    final statusCounts = Map<OrderStatus, int>.fromIterable(
      OrderStatus.values,
      value: (status) => orders.where((o) => o.status == status).length,
    );

    // Calculate daily averages
    final daysCount = end.difference(start).inDays + 1;
    final averageOrdersPerDay = totalOrders / daysCount;
    final averageRevenuePerDay = totalRevenue / daysCount;

    // Find best performing days
    final ordersByDay = <String, int>{};
    final revenueByDay = <String, double>{};

    for (var i = 0; i < daysCount; i++) {
      final date = start.add(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(date);

      ordersByDay[dayKey] = orders
          .where((order) => DateUtils.isSameDay(order.createdAt, date))
          .length;

      revenueByDay[dayKey] = orders
          .where((order) =>
              DateUtils.isSameDay(order.createdAt, date) &&
              order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.refunded)
          .fold(0, (sum, order) => sum + order.totalAmount);
    }

    final bestOrderDay = ordersByDay.isNotEmpty
        ? ordersByDay.entries.reduce((a, b) => a.value > b.value ? a : b)
        : const MapEntry('', 0);

    final bestRevenueDay = revenueByDay.isNotEmpty
        ? revenueByDay.entries.reduce((a, b) => a.value > b.value ? a : b)
        : const MapEntry('', 0.0);

    return RestaurantReport(
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      orderStatusCounts: statusCounts.entries
          .map((e) => OrderStatusCount(e.key, e.value))
          .toList(),
      averageOrdersPerDay: averageOrdersPerDay,
      averageRevenuePerDay: averageRevenuePerDay,
      bestDayForOrders: bestOrderDay.key.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(bestOrderDay.key)
          : DateTime.now(),
      bestDayForRevenue: bestRevenueDay.key.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(bestRevenueDay.key)
          : DateTime.now(),
    );
  }
}
