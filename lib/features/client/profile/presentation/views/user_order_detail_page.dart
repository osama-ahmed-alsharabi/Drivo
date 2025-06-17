import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOrderDetailsPage extends StatelessWidget {
  final Order order;
  final double exchangeRate;

  const UserOrderDetailsPage({
    super.key,
    required this.order,
    required this.exchangeRate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy hh:mm a', 'ar');
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', locale: 'ar');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('تفاصيل الطلب'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(dateFormat, context),
            const SizedBox(height: 20),
            _buildOrderItems(currencyFormat),
            const SizedBox(height: 20),
            _buildCustomerDetails(),
            const SizedBox(height: 20),
            _buildOrderSummary(currencyFormat),
            const SizedBox(height: 30),
            // Add this at the bottom of the build method's Column, just before the closing bracket
            if (order.status.value == 'shipped') _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  // Future<void> _confirmOrder(BuildContext context) async {
  //   try {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       barrierColor: Theme.of(context).primaryColor,
  //       builder: (context) =>
  //           Center(child: Image.asset(AppImages.logoWaitingGif)),
  //     );

  //     // Update order status
  //     await Supabase.instance.client.from('orders').update({
  //       'order_status': 'delivered',
  //       'updated_at': DateTime.now().toIso8601String(),
  //     }).eq('id', order.id);

  //     Navigator.pop(context); // Dismiss loading indicator

  //     CustomSnackbar(
  //         context: context,
  //         snackBarType: SnackBarType.success,
  //         label: " تم تأكيد الاستلام ");
  //     Navigator.pop(context, true); // Return to previous screen with success
  //   } catch (e) {
  //     Navigator.pop(context); // Dismiss loading indicator
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }

  Future<void> _confirmOrder(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).primaryColor,
        builder: (context) =>
            Center(child: Image.asset(AppImages.logoWaitingGif)),
      );

      // Await the async operation
      await Supabase.instance.client.from('orders').update({
        'order_status': 'delivered',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);

      if (!context.mounted) return; // Safeguard after async call
      Navigator.pop(context); // Dismiss loading indicator

      if (!context.mounted) return;
      CustomSnackbar(
        context: context,
        snackBarType: SnackBarType.success,
        label: "تم تأكيد الاستلام",
      );

      if (!context.mounted) return;
      Navigator.pop(context, true); // Return to previous screen with success
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _confirmOrder(context),
          child: const Text(
            "تأكيد الاستلام",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(DateFormat dateFormat, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الطلب',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status.value),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status.displayText),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ الطلب',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طريقة الدفع',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getPaymentMethodText(order.paymentMethod.displayText),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(NumberFormat currencyFormat) {
    final restaurantGroups = <String, List<OrderItem>>{};
    for (final item in order.items) {
      final restaurantId = item.restaurantId;
      restaurantGroups.putIfAbsent(restaurantId, () => []).add(item);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المنتجات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...restaurantGroups.keys.map((restaurantId) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المطعم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...restaurantGroups[restaurantId]!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.quantity} × ${PriceConverter.convertToYemeni(saudiPrice: item.unitPrice, exchangeRate: exchangeRate)}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '≈ ${_convertToYemeni(item.unitPrice * item.quantity, exchangeRate)} ريال يمني',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 20),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails() {
    final address = order.deliveryAddress;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل التوصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              address.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
                'سعر المنتجات',
                PriceConverter.displayConvertedPrice(
                    saudiPrice: order.subtotal, exchangeRate: exchangeRate)),
            _buildSummaryRow(
                'رسوم التوصيل',
                PriceConverter.displayConvertedPrice(
                    saudiPrice: order.deliveryFee, exchangeRate: exchangeRate)),
            if (order.discount > 0)
              _buildSummaryRow(
                  'خصم', '-${currencyFormat.format(order.discount)}'),
            const Divider(height: 20),
            // _buildSummaryRow(
            //   'المجموع الكلي',
            //   currencyFormat.format(order.totalAmount),
            //   isTotal: true,
            // ),
            const SizedBox(height: 8),
            _buildYemeniPriceRow(order.totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildYemeniPriceRow(double totalAmount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'المجموع بالريال اليمني',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '≈ ${_convertToYemeni(totalAmount, exchangeRate)} ريال يمني',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _convertToYemeni(double saudiPrice, double exchangeRate) {
    final yemeniPrice = saudiPrice * exchangeRate;
    final formatter = NumberFormat('#,###.##');
    return formatter.format(yemeniPrice);
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'قيد التجهيز';
      case 'shipped':
        return 'قيد الشحن';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.lightGreen;
      case 'preparing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'الدفع عند الاستلام';
      case 'credit_card':
        return 'بطاقة ائتمان';
      case 'wallet':
        return 'المحفظة الإلكترونية';
      default:
        return method;
    }
  }
}
