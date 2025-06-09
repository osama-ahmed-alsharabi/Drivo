// features/admin/orders/presentation/view/order_details_screen.dart
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/features/admin/admin_order/presentation/view_model/cubit/admin_orders_cubit.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  final double exchange;

  const OrderDetailsScreen(
      {super.key, required this.order, required this.exchange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'ar', symbol: 'ر.س');

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${order.orderNumber}'),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => AdminOrdersCubit(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حالة الطلب',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: order.status.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Customer Information
              _buildSectionTitle('معلومات العميل'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.person,
                        label: 'الاسم',
                        value: order.deliveryAddress.title,
                      ),
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'العنوان',
                        value: order.deliveryAddress.address,
                      ),
                      if (order.deliveryAddress.additionalInfo != null)
                        _buildDetailRow(
                          icon: Icons.info,
                          label: 'معلومات إضافية',
                          value: order.deliveryAddress.additionalInfo!,
                        ),
                      SizedBox(height: 8.h),
                      ElevatedButton.icon(
                        onPressed: () => _launchMaps(
                          order.deliveryAddress.latitude,
                          order.deliveryAddress.longitude,
                        ),
                        icon: const Icon(Icons.directions),
                        label: const Text(
                          textAlign: TextAlign.center,
                          'فتح في الخريطة',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Order Items
              _buildSectionTitle('الطلبات'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      ...order.items.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: const Icon(Icons.fastfood, size: 30),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${item.quantity} × ${PriceConverter.displayConvertedPrice(saudiPrice: item.unitPrice, exchangeRate: exchange)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${PriceConverter.convertToYemeni(saudiPrice: item.unitPrice, exchangeRate: exchange) * item.quantity}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Order Summary
              _buildSectionTitle('ملخص الطلب'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'المجموع الفرعي',
                        PriceConverter.displayConvertedPrice(
                            saudiPrice: order.subtotal, exchangeRate: exchange),
                      ),
                      _buildSummaryRow(
                        'رسوم التوصيل',
                        PriceConverter.displayConvertedPrice(
                            saudiPrice: order.deliveryFee,
                            exchangeRate: exchange),
                      ),
                      if (order.discount > 0)
                        _buildSummaryRow(
                          'الخصم',
                          '-${currencyFormat.format(order.discount)}',
                        ),
                      Divider(height: 24.h),
                      _buildSummaryRow(
                        'المجموع الكلي',
                        PriceConverter.displayConvertedPrice(
                            saudiPrice: order.totalAmount,
                            exchangeRate: exchange),
                        isTotal: true,
                      ),
                      SizedBox(height: 8.h),
                      _buildDetailRow(
                        icon: order.paymentMethod.icon,
                        label: 'طريقة الدفع',
                        value: order.paymentMethod.displayText,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Order Notes
              if (order.customerNotes != null) ...[
                _buildSectionTitle('ملاحظات العميل'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      order.customerNotes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Order Timeline
              _buildSectionTitle('سجل الطلب'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        'تم إنشاء الطلب',
                        order.createdAt,
                        icon: Icons.add_shopping_cart,
                      ),
                      if (order.updatedAt != null)
                        _buildTimelineItem(
                          'تم التحديث',
                          order.updatedAt!,
                          icon: Icons.update,
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon ?? Icons.circle, size: 16.w, color: Colors.grey),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd – hh:mm a').format(date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
