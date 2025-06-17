// features/restaurants/list/presentation/view/restaurant_list_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/features/admin/admin_facilites/presentation/view_model/cubit/admin_fetch_facilities_cubit.dart';
import 'package:drivo_app/features/admin/admin_facilites/presentation/view_model/cubit/admin_fetch_facilities_state.dart';
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/restaurant_report_view.dart';
import 'package:drivo_app/features/client/restaurant_list/presentation/view/restaurant_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class AdminFetchFacilities extends StatelessWidget {
  const AdminFetchFacilities({super.key});

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن مطعم...',
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
          context.read<AdminFetchFacilitiesCubit>().filterRestaurants(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المطاعم'),
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocProvider(
                create: (context) =>
                    AdminFetchFacilitiesCubit()..fetchRestaurants(),
                child: BlocConsumer<AdminFetchFacilitiesCubit,
                    AdminFetchFacilitiesState>(
                  listener: (context, state) {
                    if (state is AdminFetchFacilitiesError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AdminFetchFacilitiesLoading) {
                      return _buildShimmerLoading();
                    } else if (state is AdminFetchFacilitiesError) {
                      return Center(child: Text('حدث خطأ: ${state.message}'));
                    } else if (state is RestaurantListEmpty) {
                      return const Center(child: Text('لا توجد مطاعم متاحة'));
                    } else if (state is AdminFetchFacilitiesLoaded) {
                      return LiquidPullToRefresh(
                          onRefresh: () async {
                            await BlocProvider.of<AdminFetchFacilitiesCubit>(
                                    context)
                                .fetchRestaurants();
                          },
                          child: _buildRestaurantList(state.restaurants));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<Map<String, dynamic>> restaurants) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.6,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return _RestaurantCard(restaurant: restaurant);
      },
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
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

class _RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AdminFetchFacilitiesCubit>();
    final averageRating = restaurant['average_rating'] ?? 0.0;
    final totalRatings = restaurant['total_ratings'] ?? 0;

    return GestureDetector(
      onTap: () => _navigateToRestaurantProfile(context, restaurant),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: CachedNetworkImage(
                    imageUrl: restaurant['logo_url'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
              ),

              // Restaurant Info
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['facility_name'] ?? 'مطعم',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16.w),
                        SizedBox(width: 4.w),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '($totalRatings)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.location_on, size: 16.w, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            restaurant['directorate'] ?? 'غير محدد',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: InkWell(
                        onTap: () => cubit.toggleRestaurantStatus(
                          restaurant['id'].toString(),
                          restaurant['is_active'] ?? false,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: restaurant['is_active'] ?? false
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            restaurant['is_active'] ?? false
                                ? "مفعل"
                                : "غير مفعل",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: InkWell(
                        onTap: () {
                          // Example usage in your navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantReportView(
                                restaurantId: restaurant['id'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "التقارير",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRestaurantProfile(
      BuildContext context, Map<String, dynamic> restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantProfileScreen(restaurant: restaurant),
      ),
    );
  }
}

void _navigateToRestaurantProfile(
    BuildContext context, Map<String, dynamic> restaurant) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RestaurantProfileScreen(restaurant: restaurant),
    ),
  );
}
