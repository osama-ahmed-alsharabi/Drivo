// features/admin/deliveries/presentation/view/admin_deliveries_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/features/admin/admin_delivery/presentation/view/delivery_details_screen.dart';
import 'package:drivo_app/features/admin/admin_delivery/presentation/view_model/cubit/admin_deliveries_cubit.dart';
import 'package:drivo_app/features/admin/admin_delivery/presentation/view_model/cubit/admin_deliveries_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class AdminDeliveriesScreen extends StatelessWidget {
  const AdminDeliveriesScreen({super.key});

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'ابحث عن مندوب...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        onChanged: (value) {
          context.read<AdminDeliveriesCubit>().filterDeliveries(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المندوبين'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocProvider(
              create: (context) => AdminDeliveriesCubit()..fetchDeliveries(),
              child: BlocConsumer<AdminDeliveriesCubit, AdminDeliveriesState>(
                listener: (context, state) {
                  if (state is AdminDeliveriesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AdminDeliveriesLoading) {
                    return _buildShimmerLoading();
                  } else if (state is AdminDeliveriesError) {
                    return Center(
                      child: Text(
                        'حدث خطأ: ${state.message}',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    );
                  } else if (state is DeliveriesListEmpty) {
                    return const Center(
                      child: Text('لا توجد مناديب متاحة حالياً'),
                    );
                  } else if (state is AdminDeliveriesLoaded) {
                    return LiquidPullToRefresh(
                        onRefresh: () async {
                          await BlocProvider.of<AdminDeliveriesCubit>(context)
                              .fetchDeliveries();
                        },
                        child: _buildDeliveriesList(state.deliveries));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesList(List<Map<String, dynamic>> deliveries) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _DeliveryCard(delivery: delivery);
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
            height: 100.h,
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

class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AdminDeliveriesCubit>();
    final dateFormat = DateFormat('yyyy-MM-dd – hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDeliveryDetails(context, delivery),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery['user_name'] ?? 'مندوب',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => cubit.toggleDeliveryStatus(
                      delivery['id'].toString(),
                      delivery['is_active'] ?? false,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: delivery['is_active'] ?? false
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        delivery['is_active'] ?? false ? "مفعل" : "غير مفعل",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.phone, size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    delivery['phone_number'] ?? 'غير متوفر',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.email, size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    delivery['email'] ?? 'غير متوفر',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16.w, color: theme.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    delivery['directorate'] ?? 'غير محدد',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(DateTime.parse(delivery['created_at'])),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDeliveryDetails(
      BuildContext context, Map<String, dynamic> delivery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(delivery: delivery),
      ),
    );
  }
}
