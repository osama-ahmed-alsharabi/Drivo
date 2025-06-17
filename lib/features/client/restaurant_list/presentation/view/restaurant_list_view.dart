// features/restaurants/list/presentation/view/restaurant_list_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/restaurant_list/presentation/view/restaurant_profile_screen.dart';
import 'package:drivo_app/features/client/restaurant_list/presentation/view_model/cubit/restaurant_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المطاعم'),
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // _buildSearchField(context),
            Expanded(
              child: BlocProvider(
                create: (context) => RestaurantListCubit()..fetchRestaurants(),
                child: Builder(builder: (context) {
                  return BlocBuilder<RestaurantListCubit, RestaurantListState>(
                    builder: (context, state) {
                      return LiquidPullToRefresh(
                        onRefresh: () async {
                          await context
                              .read<RestaurantListCubit>()
                              .fetchRestaurants();
                        },
                        color: Theme.of(context).primaryColor,
                        height: 100,
                        animSpeedFactor: 1,
                        child: _buildContent(state),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RestaurantListState state) {
    if (state is RestaurantListLoading) {
      return _buildShimmerLoading();
    } else if (state is RestaurantListError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is RestaurantListEmpty) {
      return const Center(child: Text('لا توجد مطاعم متاحة'));
    } else if (state is RestaurantListLoaded) {
      return _buildRestaurantList(state.restaurants);
    }
    return const SizedBox();
  }

  Widget _buildRestaurantList(List<Map<String, dynamic>> restaurants) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
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
                          '${restaurant['average_rating']?.toStringAsFixed(1) ?? '0.0'}',
                          style: theme.textTheme.bodySmall,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${restaurant['total_ratings'] ?? 0})',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
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
                    Row(
                      children: [
                        SizedBox(width: 4.w),
                        // Expanded(
                        //   child:
                        // ),
                      ],
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

  static String? userId;
  _getUserId() async {
    userId = await SharedPreferencesService.getUserId();
    return userId != null;
  }

  void _navigateToRestaurantProfile(
      BuildContext context, Map<String, dynamic> restaurant) async {
    await _getUserId();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantProfileScreen(
          restaurant: restaurant,
          userId: userId,
        ),
      ),
    );
  }
}
