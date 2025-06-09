import 'package:drivo_app/features/client/cart/data/model/order_model.dart';

abstract class AdminReportState {}

class AdminReportInitial extends AdminReportState {}

class AdminReportLoading extends AdminReportState {}

class AdminReportLoaded extends AdminReportState {
  final AdminReport report;

  AdminReportLoaded(this.report);
}

class AdminReportError extends AdminReportState {
  final String message;

  AdminReportError(this.message);
}

// lib/features/admin/report/data/models/admin_report.dart

class AdminReport {
  final int newClients;
  final int newFacilities;
  final int totalOrders;
  final double totalRevenue;
  final List<OrderStatusCount> orderStatusCounts;
  final double averageOrdersPerDay;
  final double averageRevenuePerDay;
  final DateTime bestDayForOrders;
  final DateTime bestDayForRevenue;

  AdminReport({
    required this.newClients,
    required this.newFacilities,
    required this.totalOrders,
    required this.totalRevenue,
    required this.orderStatusCounts,
    required this.averageOrdersPerDay,
    required this.averageRevenuePerDay,
    required this.bestDayForOrders,
    required this.bestDayForRevenue,
  });
}

class OrderStatusCount {
  final OrderStatus status;
  final int count;

  OrderStatusCount(this.status, this.count);
}
