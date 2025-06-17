// lib/features/restaurant/report/presentation/views/restaurant_report_view.dart
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/view_model/cubit/restaurant_report_cubit.dart';
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/view_model/cubit/restaurant_report_state.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class RestaurantReportView extends StatelessWidget {
  final String restaurantId;

  const RestaurantReportView({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RestaurantReportCubit(restaurantId: restaurantId)..fetchReport(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('تقرير المطعم'),
          centerTitle: true,
        ),
        body: BlocBuilder<RestaurantReportCubit, RestaurantReportState>(
          builder: (context, state) {
            return LiquidPullToRefresh(
              onRefresh: () async =>
                  context.read<RestaurantReportCubit>().fetchReport(),
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    final cubit = context.read<RestaurantReportCubit>();
    final now = DateTime.now();
    final initialStart =
        cubit.startDate ?? now.subtract(const Duration(days: 7));
    final initialEnd = cubit.endDate ?? now;

    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
    ).then((pickedRange) {
      if (pickedRange != null) {
        cubit.setDateRange(pickedRange.start, pickedRange.end);
      }
    });
  }

  Widget _buildBody(BuildContext context, RestaurantReportState state) {
    if (state is RestaurantReportLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is RestaurantReportError) {
      return Center(child: Text('حدث خطأ: ${state.message}'));
    } else if (state is RestaurantReportLoaded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state),
            const SizedBox(height: 24),
            _buildSummaryCards(state.report),
            const SizedBox(height: 32),
            _buildDetailedStats(state.report, context),
          ],
        ),
      );
    }
    return const Center(child: Text('اسحب للتحديث'));
  }

  Widget _buildHeader(BuildContext context, RestaurantReportLoaded state) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final rangeText = state.startDate != null && state.endDate != null
        ? '${dateFormat.format(state.startDate!)} - ${dateFormat.format(state.endDate!)}'
        : 'اختر فترة زمنية';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقرير المطعم',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              onPressed: () => _showDatePicker(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          rangeText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blueGrey[600],
              ),
        ),
        const Divider(thickness: 1, height: 32),
      ],
    );
  }

  Widget _buildSummaryCards(RestaurantReport report) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildSummaryCard(
          title: 'الطلبات',
          value: report.totalOrders,
          icon: Icons.shopping_cart,
          color: Colors.amber,
        ),
        _buildSummaryCard(
          title: 'الإيرادات',
          value: report.totalRevenue,
          isCurrency: true,
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required num value,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            FittedBox(
              child: Text(
                isCurrency
                    ? NumberFormat.currency(symbol: 'ر.ي').format(value)
                    : '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(RestaurantReport report, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات مفصلة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildStatItem(
          title: 'متوسط الطلبات اليومية',
          value: report.averageOrdersPerDay.toStringAsFixed(1),
        ),
        _buildStatItem(
          title: 'متوسط الإيرادات اليومية',
          value: NumberFormat.currency(symbol: 'ر.ي')
              .format(report.averageRevenuePerDay),
        ),
        _buildStatItem(
          title: 'أعلى يوم في الطلبات',
          value: DateFormat('yyyy-MM-dd').format(report.bestDayForOrders),
        ),
        _buildStatItem(
          title: 'أعلى يوم في الإيرادات',
          value: DateFormat('yyyy-MM-dd').format(report.bestDayForRevenue),
        ),
      ],
    );
  }

  Widget _buildStatItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/restaurant/report/data/model/restaurant_report_model.dart

class RestaurantReport {
  final int totalOrders;
  final double totalRevenue;
  final List<OrderStatusCount> orderStatusCounts;
  final double averageOrdersPerDay;
  final double averageRevenuePerDay;
  final DateTime bestDayForOrders;
  final DateTime bestDayForRevenue;

  RestaurantReport({
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
