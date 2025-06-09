import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/product_grid_view_widget.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_products/fetch_client_products_cubit.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantProfileScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String? userId;

  const RestaurantProfileScreen(
      {super.key, required this.restaurant, this.userId});

  @override
  State<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        uri.hasAuthority &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.h,
              pinned: true,
              backgroundColor: theme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildCoverImage(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(theme, isDarkMode, context),
                    SizedBox(height: 24.h),
                    // _buildStatisticsCards(theme),
                    SizedBox(height: 24.h),
                    _buildAboutSection(theme),
                    SizedBox(height: 24.h),
                    _buildContactSection(theme, context),
                    SizedBox(height: 24.h),
                    _buildBusinessHours(theme),
                    SizedBox(height: 24.h),
                    _buildProductsSection(
                        theme, context, widget.restaurant['id']),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final coverUrl = widget.restaurant['cover_image_url'];
    if (coverUrl != null && coverUrl.toString().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.restaurant, size: 80)),
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant, size: 80),
      );
    }
  }

  Widget _buildProfileHeader(
      ThemeData theme, bool isDarkMode, BuildContext context) {
    // String? userId = await SharedPreferencesService.getUserId();
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
                widget.restaurant['facility_name'] ?? 'مطعم',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.restaurant['facility_category'] ?? 'مطعم',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    '${widget.restaurant['average_rating']?.toStringAsFixed(1) ?? '0.0'} (${widget.restaurant['total_ratings'] ?? 0} تقييم)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              // Add this in the _buildProfileHeader method, after the rating display row
              const SizedBox(
                height: 15,
              ),
              if (widget.userId != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.star_rate),
                        label: const Text('قيم المطعم'),
                        onPressed: () => _showRatingBottomSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
                border: Border.all(color: Colors.white, width: 3.w),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _buildLogoImage(theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoImage(ThemeData theme) {
    if (isValidUrl(widget.restaurant['cover_image_url'])) {
      return CachedNetworkImage(
        imageUrl: widget.restaurant['cover_image_url'],
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.restaurant, size: 80)),
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant, size: 80),
      );
    }
  }

  Widget _buildRatingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التقييمات',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        // You can fetch and display actual reviews here
        // For now, we'll just show a button to see all reviews
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showAllReviews(),
            child: const Text('عرض جميع التقييمات'),
          ),
        ),
      ],
    );
  }

  void _showAllReviews() {
    // Implement navigation to a full reviews screen
  }

  Future<void> _refreshRatings(BuildContext context) async {
    try {
      final response =
          await Supabase.instance.client.from('facilities').select('''
          ratings:ratings(
            rating
          )
        ''').eq('id', widget.restaurant['id']).single();

      final ratings =
          List<Map<String, dynamic>>.from(response['ratings'] ?? []);
      final totalRatings = ratings.length;
      final averageRating = totalRatings > 0
          ? ratings.map((r) => r['rating'] as num).reduce((a, b) => a + b) /
              totalRatings
          : 0.0;

      setState(() {
        widget.restaurant['average_rating'] = averageRating;
        widget.restaurant['total_ratings'] = totalRatings;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to refresh ratings'),
        ),
      );
    }
  }

  void _showRatingBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    double rating = 0;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'تقييم المطعم',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: StarRating(
                        rating: rating,
                        onRatingChanged: (newRating) {
                          setState(() {
                            rating = newRating;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'اكتب تعليقك (اختياري)',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'كيف كانت تجربتك؟',
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (rating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء اختيار تقييم'),
                              ),
                            );
                            return;
                          }

                          // Submit the rating
                          await _submitRating(
                            context,
                            rating,
                            reviewController.text,
                          );

                          Navigator.pop(context);
                        },
                        child: const Text('تأكيد التقييم'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(
    BuildContext context,
    double rating,
    String review,
  ) async {
    try {
      final userId = await SharedPreferencesService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      await Supabase.instance.client.from('ratings').insert({
        'restaurant_id': widget.restaurant['id'],
        'user_id': userId,
        'rating': rating,
        'review': review.isNotEmpty ? review : null,
        'created_at': DateTime.now().toIso8601String(),
      });
      await _refreshRatings(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('شكراً لتقييمك!'),
          backgroundColor: Colors.green,
        ),
      );

      // You might want to refresh the restaurant data to show the new rating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إرسال التقييم: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatisticsCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(theme,
                icon: Icons.shopping_basket, value: '1,248', label: 'الطلبات')),
        SizedBox(width: 12.w),
        Expanded(
            child: _buildStatCard(theme,
                icon: Icons.thumb_up, value: '92%', label: 'رضا العملاء')),
        SizedBox(width: 12.w),
        Expanded(
            child: _buildStatCard(theme,
                icon: Icons.timer, value: '15-30', label: 'دقيقة')),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme,
      {required IconData icon, required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24.w, color: theme.primaryColor),
          SizedBox(height: 8.h),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('حول المطعم',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text(widget.restaurant['description'] ?? 'لا يوجد وصف',
            style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildContactSection(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلومات التواصل',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        _buildContactItem(theme,
            icon: Icons.location_on,
            title: 'العنوان',
            value: widget.restaurant['address'] ?? 'لا يوجد عنوان',
            onTap: () => _showLocationOnMap(widget.restaurant['latitude'],
                widget.restaurant['longitude'], context)),
        _buildContactItem(theme,
            icon: Icons.phone,
            title: 'الهاتف',
            value: widget.restaurant['phone_number'] ?? 'لا يوجد رقم هاتف'),
        _buildContactItem(theme,
            icon: Icons.email,
            title: 'البريد الإلكتروني',
            value: widget.restaurant['email'] ?? 'لا يوجد بريد إلكتروني'),
      ],
    );
  }

  Widget _buildContactItem(ThemeData theme,
      {required IconData icon,
      required String title,
      required String value,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: theme.primaryColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                  SizedBox(height: 2.h),
                  Text(value, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHours(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('أوقات العمل',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        _buildHourItem(theme, 'السبت - الأربعاء',
            '${widget.restaurant['opening_hours_sun_thu'] ?? '10:00 ص'} - ${widget.restaurant['closing_hours_sun_thu'] ?? '12:00 ص'}'),
        _buildHourItem(theme, 'الجمعة',
            '${widget.restaurant['opening_hours_fri'] ?? '4:00 م'} - ${widget.restaurant['closing_hours_fri'] ?? '1:00 ص'}'),
        _buildHourItem(theme, 'الخميس',
            '${widget.restaurant['opening_hours_sat'] ?? '12:00 م'} - ${widget.restaurant['closing_hours_sat'] ?? '12:00 ص'}'),
      ],
    );
  }

  Widget _buildHourItem(ThemeData theme, String day, String hours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(child: Text(day, style: theme.textTheme.bodyMedium)),
          Text(hours,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductsSection(ThemeData theme, context, restauratsId) {
    List<ProductModel> products =
        BlocProvider.of<FetchClientProductsCubit>(context).products;
    List<ProductModel> products2 =
        products.where((e) => e.restaurantId == restauratsId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('قائمة الطعام',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        ProductGridViewWidget(productModel: products2, isFavoriteView: false),
      ],
    );
  }

  Future<void> _showLocationOnMap(
      double? latitude, double? longitude, BuildContext context) async {
    if (latitude == null || longitude == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text('موقع المطعم'),
          ),
          body: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 15),
            markers: {
              Marker(
                  markerId: const MarkerId('facility_location'),
                  position: LatLng(latitude, longitude)),
            },
          ),
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40.w,
          ),
        );
      }),
    );
  }
}
