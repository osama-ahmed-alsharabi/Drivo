// lib/features/admin/report/presentation/cubit/admin_report_cubit.dart
import 'dart:async';
import 'package:drivo_app/features/admin/admin_reports/presentation/view_model/cubit/reports_state.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReportCubit extends Cubit<AdminReportState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  AdminReportCubit() : super(AdminReportInitial());

  Future<void> fetchReport() async {
    emit(AdminReportLoading());
    try {
      final report = await _generateReport();
      emit(AdminReportLoaded(report));
    } catch (e) {
      emit(AdminReportError(e.toString()));
    }
  }

  Future<AdminReport> _generateReport() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Fetch new clients
    final clientsResponse = await supabaseClient
        .from('clients')
        .select()
        .gte('created_at', sevenDaysAgo.toIso8601String());
    final newClients = clientsResponse.length;

    // Fetch new facilities
    final facilitiesResponse = await supabaseClient
        .from('facilities')
        .select()
        .gte('created_at', sevenDaysAgo.toIso8601String());
    final newFacilities = facilitiesResponse.length;

    // Fetch orders
    final ordersResponse = await supabaseClient
        .from('orders')
        .select()
        .gte('created_at', sevenDaysAgo.toIso8601String());

    final orders = ordersResponse.map((json) => Order.fromJson(json)).toList();
    final totalOrders = orders.length;

    // Calculate revenue
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
    final daysCount = now.difference(sevenDaysAgo).inDays;
    final averageOrdersPerDay = totalOrders / daysCount;
    final averageRevenuePerDay = totalRevenue / daysCount;

    // Find best performing days
    final ordersByDay = <String, int>{};
    final revenueByDay = <String, double>{};

    for (var i = 0; i <= daysCount; i++) {
      final date = sevenDaysAgo.add(Duration(days: i));
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

    final bestOrderDay =
        ordersByDay.entries.reduce((a, b) => a.value > b.value ? a : b);
    final bestRevenueDay =
        revenueByDay.entries.reduce((a, b) => a.value > b.value ? a : b);

    return AdminReport(
      newClients: newClients,
      newFacilities: newFacilities,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      orderStatusCounts: statusCounts.entries
          .map((e) => OrderStatusCount(e.key, e.value))
          .toList(),
      averageOrdersPerDay: averageOrdersPerDay,
      averageRevenuePerDay: averageRevenuePerDay,
      bestDayForOrders: DateFormat('yyyy-MM-dd').parse(bestOrderDay.key),
      bestDayForRevenue: DateFormat('yyyy-MM-dd').parse(bestRevenueDay.key),
    );
  }
}
