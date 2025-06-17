// features/admin/orders/presentation/view/admin_orders_screen.dart
import 'package:drivo_app/features/admin/admin_order/presentation/view/order_details_screen.dart';
import 'package:drivo_app/features/admin/admin_order/presentation/view_model/cubit/admin_orders_cubit.dart';
import 'package:drivo_app/features/admin/admin_order/presentation/view_model/cubit/admin_orders_state.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocProvider(
              create: (context) => AdminOrdersCubit()..fetchOrders(),
              child: Builder(builder: (context) {
                return BlocConsumer<AdminOrdersCubit, AdminOrdersState>(
                  listener: (context, state) async {
                    if (state is AdminOrdersError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is OrderStatusUpdated) {
                      await BlocProvider.of<AdminOrdersCubit>(context)
                          .fetchOrders();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث حالة الطلب بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AdminOrdersLoading) {
                      return _buildShimmerLoading();
                    } else if (state is AdminOrdersError) {
                      return Center(
                        child: Text(
                          'حدث خطأ: ${state.message}',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    } else if (state is OrdersListEmpty) {
                      return const Center(
                        child: Text('لا توجد طلبات متاحة حالياً'),
                      );
                    } else if (state is AdminOrdersLoaded) {
                      return LiquidPullToRefresh(
                        onRefresh: () async {
                          await BlocProvider.of<AdminOrdersCubit>(context)
                              .fetchOrders();
                        },
                        child:
                            _buildOrdersList(state.orders, state.exchange ?? 1),
                      );
                    }
                    return const SizedBox();
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, double exchange) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order,
          exchange: exchange,
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final double exchange;
  const _OrderCard({required this.order, required this.exchange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd – hh:mm a');
    final currencyFormat = NumberFormat.currency(locale: 'ar', symbol: 'ر.س');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToOrderDetails(context, order, exchange),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'الطلب #${order.orderNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      order.status.displayText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: order.status.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    order.deliveryAddress.title,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    dateFormat.format(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.payments, size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    order.paymentMethod.displayText,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(order.totalAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // In the order status card, modify to show this:
              if (order.status == OrderStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await BlocProvider.of<AdminOrdersCubit>(context)
                          .acceptOrder(order.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(order.needsDeliveryFeeCalculation ?? false
                        ? 'حساب رسوم التوصيل وتأكيد'
                        : 'تأكيد الطلب'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOrderDetails(
      BuildContext context, Order order, double exchange) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: order,
          exchange: exchange,
        ),
      ),
    );
  }
}
