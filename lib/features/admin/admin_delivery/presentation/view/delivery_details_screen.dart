// features/admin/deliveries/presentation/view/delivery_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd – hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المندوب'),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: delivery['avatar_url'] != null
                    ? CachedNetworkImageProvider(delivery['avatar_url'])
                    : null,
                child: delivery['avatar_url'] == null
                    ? Icon(Icons.person, size: 40.w, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 20.h),
            _buildDetailItem(
              context,
              title: 'الاسم',
              value: delivery['user_name'] ?? 'غير متوفر',
              icon: Icons.person,
            ),
            _buildDetailItem(
              context,
              title: 'رقم الهاتف',
              value: delivery['phone_number'] ?? 'غير متوفر',
              icon: Icons.phone,
            ),
            _buildDetailItem(
              context,
              title: 'البريد الإلكتروني',
              value: delivery['email'] ?? 'غير متوفر',
              icon: Icons.email,
            ),
            _buildDetailItem(
              context,
              title: 'المحافظة',
              value: delivery['directorate'] ?? 'غير محدد',
              icon: Icons.location_on,
            ),
            if (delivery['delivery_license'] != null)
              _buildDetailItem(
                context,
                title: 'رقم رخصة التوصيل',
                value: delivery['delivery_license'],
                icon: Icons.card_membership,
              ),
            _buildDetailItem(
              context,
              title: 'حالة الحساب',
              value: delivery['is_active'] ?? false ? "مفعل" : "غير مفعل",
              icon: delivery['is_active'] ?? false
                  ? Icons.check_circle
                  : Icons.cancel,
              iconColor:
                  delivery['is_active'] ?? false ? Colors.green : Colors.red,
            ),
            _buildDetailItem(
              context,
              title: 'تاريخ الإنشاء',
              value: dateFormat.format(DateTime.parse(delivery['created_at'])),
              icon: Icons.calendar_today,
            ),
            if (delivery['updated_at'] != null)
              _buildDetailItem(
                context,
                title: 'تاريخ التحديث',
                value:
                    dateFormat.format(DateTime.parse(delivery['updated_at'])),
                icon: Icons.update,
              ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                'معلومات إضافية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Add any additional information here
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: iconColor ?? theme.primaryColor),
          SizedBox(width: 8.w),
          Text(
            '$title: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
