import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/features/service_provider/edit_service_profile_screen/presentation/view/settings_view.dart';
import 'package:drivo_app/features/service_provider/profile_provider/Presentation/view/logout_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../view_model/cubit/service_provider_profile_cubit.dart';

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
  late final ServiceProviderProfileCubit _cubit;
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _cubit = ServiceProviderProfileCubit(
      supabaseClient: Supabase.instance.client,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataFetched) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        _cubit.fetchProfileData(userId);
        _dataFetched = true;
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => _cubit,
      child:
          BlocBuilder<ServiceProviderProfileCubit, ServiceProviderProfileState>(
        builder: (context, state) {
          if (state is ServiceProviderProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ServiceProviderProfileError) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.message}')),
            );
          }

          if (state is ServiceProviderProfileLoaded) {
            final profileData = state.profileData;
            return _buildProfileScreen(theme, isDarkMode, profileData, state);
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Scaffold _buildProfileScreen(ThemeData theme, bool isDarkMode,
      Map<String, dynamic> profileData, state) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: LiquidPullToRefresh(
          onRefresh: () async {
            if (!_dataFetched) {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                _cubit.fetchProfileData(userId);
                _dataFetched = true;
              }
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.h,
                pinned: true,
                backgroundColor: theme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: profileData['cover_image_url'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () =>
                        _navigateToEditProfile(context, profileData, state),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Section
                      _buildProfileHeader(theme, isDarkMode, profileData),
                      SizedBox(height: 24.h),

                      // Statistics Cards
                      // _buildStatisticsCards(theme, profileData),
                      SizedBox(height: 24.h),

                      // About Section
                      _buildAboutSection(theme, profileData),
                      SizedBox(height: 24.h),

                      // Contact Information
                      _buildContactSection(theme, profileData),
                      SizedBox(height: 24.h),

                      // Business Hours
                      _buildBusinessHours(theme, profileData),

                      SizedBox(height: 24.h),
                      const LogoutButtonWidgetServiceProvider(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      ThemeData theme, bool isDarkMode, Map<String, dynamic> profileData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: 40.h),
          padding:
              EdgeInsets.only(top: 60.h, left: 16.w, right: 16.w, bottom: 16.h),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                profileData['facility_name'] ?? 'مطعم',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                profileData['facility_category'] ?? 'مطعم',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    '${profileData['average_rating']?.toStringAsFixed(1) ?? '0.0'} (${profileData['total_ratings'] ?? 0} تقييم)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3.w,
                ),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: profileData['logo_url'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.restaurant),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, Map<String, dynamic> profileData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حول المطعم',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          profileData['description'] ?? 'لا يوجد وصف',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildContactSection(
      ThemeData theme, Map<String, dynamic> profileData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التواصل',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildContactItem(
          theme,
          icon: Icons.location_on,
          title: 'العنوان',
          value: profileData['address'] ?? 'لا يوجد عنوان',
          onTap: () => _showLocationOnMap(
            profileData['latitude'],
            profileData['longitude'],
          ),
        ),
        _buildContactItem(
          theme,
          icon: Icons.phone,
          title: 'الهاتف',
          value: profileData['phone_number'] ?? 'لا يوجد رقم هاتف',
        ),
        _buildContactItem(
          theme,
          icon: Icons.email,
          title: 'البريد الإلكتروني',
          value: profileData['email'] ?? 'لا يوجد بريد إلكتروني',
        ),
      ],
    );
  }

  Widget _buildContactItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.w, color: theme.primaryColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHours(
      ThemeData theme, Map<String, dynamic> profileData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أوقات العمل',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildHourItem(
          theme,
          'السبت - الأربعاء',
          '${profileData['opening_hours_sun_thu'] ?? '10:00 ص'} - ${profileData['closing_hours_sun_thu'] ?? '12:00 ص'}',
        ),
        _buildHourItem(
          theme,
          'الجمعة',
          '${profileData['opening_hours_fri'] ?? '4:00 م'} - ${profileData['closing_hours_fri'] ?? '1:00 ص'}',
        ),
        _buildHourItem(
          theme,
          'الخميس',
          '${profileData['opening_hours_sat'] ?? '12:00 م'} - ${profileData['closing_hours_sat'] ?? '12:00 ص'}',
        ),
      ],
    );
  }

  Widget _buildHourItem(ThemeData theme, String day, String hours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            hours,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, profileData, state) {
    if (state is ServiceProviderProfileLoaded) {
      final profileData = (state).profileData;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditServiceProviderProfileScreen(
            provider: profileData,
          ),
        ),
      ).then((updated) {
        if (updated == true) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            context
                .read<ServiceProviderProfileCubit>()
                .fetchProfileData(userId);
          }
        }
      });
    }
  }

  Future<void> _showLocationOnMap(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('موقع المطعم')),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('facility_location'),
                position: LatLng(latitude, longitude),
              ),
            },
          ),
        ),
      ),
    );
  }
}
