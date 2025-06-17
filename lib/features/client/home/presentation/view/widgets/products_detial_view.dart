import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/core/service/auth_service.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/auth/login/presentation/view/login_view.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  bool _isFavorite = false;
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;
  Map<String, dynamic>? _facilityData;
  bool _isLoadingFacility = true;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _favoriteAnimation = CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    );
    _fetchFacilityData();
  }

  Future<void> _fetchFacilityData() async {
    try {
      final facility =
          await SupabaseService().getFacilityById(widget.product.restaurantId);
      setState(() {
        _facilityData = facility;
        _isLoadingFacility = false;
      });
    } catch (e) {
      setState(() => _isLoadingFacility = false);
    }
  }

  bool _isRestaurantOpen() {
    if (_facilityData == null) return false;

    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final dayOfWeek = now.weekday;

    String? openingTimeStr;
    String? closingTimeStr;

    if (dayOfWeek == DateTime.saturday ||
        dayOfWeek == DateTime.sunday ||
        dayOfWeek == DateTime.monday ||
        dayOfWeek == DateTime.tuesday ||
        dayOfWeek == DateTime.wednesday) {
      openingTimeStr = _facilityData!['opening_hours_sun_thu'];
      closingTimeStr = _facilityData!['closing_hours_sun_thu'];
    } else if (dayOfWeek == DateTime.thursday) {
      openingTimeStr = _facilityData!['opening_hours_sat'];
      closingTimeStr = _facilityData!['closing_hours_sat'];
    } else if (dayOfWeek == DateTime.friday) {
      openingTimeStr = _facilityData!['opening_hours_fri'];
      closingTimeStr = _facilityData!['closing_hours_fri'];
    }

    final openingTime = _parseTime(openingTimeStr);
    final closingTime = _parseTime(closingTimeStr);

    if (openingTime == null || closingTime == null) return false;

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    if (closingMinutes < openingMinutes) {
      return currentMinutes >= openingMinutes ||
          currentMinutes < closingMinutes;
    } else {
      return currentMinutes >= openingMinutes &&
          currentMinutes < closingMinutes;
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;

    try {
      if (timeStr.toLowerCase().contains("am") ||
          timeStr.toLowerCase().contains("pm")) {
        final format = DateFormat('h:mm a', 'en_US');
        final date = format.parse(timeStr);
        return TimeOfDay.fromDateTime(date);
      } else {
        final parts = timeStr.split(':');
        if (parts.length < 2) return null;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) return null;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        _favoriteController.forward(from: 0);
      } else {
        _favoriteController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.product.imageUrl == null
                        ? Container(
                            color: theme.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag,
                                size: 80,
                                color: theme.primaryColor,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(theme.primaryColor),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child:
                                  Icon(Icons.error, color: theme.primaryColor),
                            ),
                          ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (widget.product.category != null)
                              Text(
                                widget.product.category!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ).animate().fadeIn(delay: 100.ms).slideX(
                              begin: 0.2,
                              curve: Curves.easeOutCubic,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${PriceConverter.formatNumberWithCommas(PriceConverter.convertToYemeni(
                              saudiPrice: widget.product.price,
                              exchangeRate: widget.product.exchangeRate ?? 1,
                            ))} ر.ي',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            backgroundColor: widget.product.isAvailable
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            label: Text(
                              widget.product.isAvailable
                                  ? 'متوفر'
                                  : 'غير متوفر',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: widget.product.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideX(
                            begin: -0.2,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ScaleTransition(
                      scale: _favoriteAnimation,
                      child: FloatingActionButton(
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        elevation: 0,
                        onPressed: _toggleFavorite,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: _isFavorite
                              ? const Icon(
                                  Icons.favorite,
                                  key: ValueKey('filled'),
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  key: const ValueKey('outlined'),
                                  color: theme.primaryColor,
                                ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ),
                  const SizedBox(height: 24),
                  if (widget.product.description != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل المنتج',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideY(
                          begin: 0.2,
                          curve: Curves.easeOutCubic,
                        ),
                  const SizedBox(height: 32),
                  Text(
                    'اختر الكمية',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).animate().fadeIn(delay: 550.ms),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _quantity.toString(),
                          style: theme.textTheme.headlineSmall,
                        ).animate().fadeIn(delay: 600.ms),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).animate().fadeIn(delay: 650.ms),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text(
                          'أضف للسلة',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_isLoadingFacility) {
                            CustomSnackbar(
                              context: context,
                              snackBarType: SnackBarType.alert,
                              label: "جاري التحقق من وقت عمل المطعم...",
                            );
                            return;
                          }

                          if (_facilityData == null || !_isRestaurantOpen()) {
                            CustomSnackbar(
                              context: context,
                              snackBarType: SnackBarType.fail,
                              label: "المطعم غير متاح للطلب حاليًا",
                            );
                            return;
                          }

                          if (!widget.product.isAvailable) {
                            CustomSnackbar(
                              context: context,
                              snackBarType: SnackBarType.fail,
                              label: "الكمية غير متوفرة",
                            );
                            return;
                          }

                          var email = await SharedPreferencesService.getEmail();
                          if (email == null) {
                            if (!context.mounted) return;
                            _showOrderConfirmation(context);
                            return;
                          }
                          if (!context.mounted) return;
                          context
                              .read<CartCubit>()
                              .addToCart(widget.product, quantity: _quantity);
                          CustomSnackbar(
                            context: context,
                            snackBarType: SnackBarType.success,
                            label: 'تمت إضافة ${widget.product.name} إلى السلة',
                          );
                        },
                      ).animate().fadeIn(delay: 700.ms),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("قم بتسجيل الدخول"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text("يجب عليك تسجيل الدخول اولا"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginView()));
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
