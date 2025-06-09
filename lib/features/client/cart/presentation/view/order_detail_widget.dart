import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool? isFree;
  final double exchangeRate;

  const OrderDetailsPage(
      {super.key,
      required this.order,
      required this.exchangeRate,
      this.isFree});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س');

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
            _buildOrderHeader(dateFormat),
            const SizedBox(height: 20),
            _buildOrderItems(currencyFormat, exchangeRate),
            const SizedBox(height: 20),
            _buildCustomerDetails(),
            const SizedBox(height: 20),
            _buildOrderSummary(currencyFormat, exchangeRate, isFree),
            const SizedBox(height: 30),
            _buildPrintButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(DateFormat dateFormat) {
    return Row(
      children: [
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateFormat.format(DateTime.parse(order['created_at'])),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              order['order_number'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order['order_status']),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(order['order_status']),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItems(NumberFormat currencyFormat, exchangeRate) {
    // Group items by restaurant
    final restaurantGroups = <String, List<dynamic>>{};
    for (final item in order['items']) {
      final restaurantId = item['restaurant_id'];
      restaurantGroups.putIfAbsent(restaurantId, () => []).add(item);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final restaurantId in restaurantGroups.keys)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantGroups[restaurantId]?.first['restaurant_name'] ??
                        'المطعم',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...restaurantGroups[restaurantId]!.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['quantity']} × ${PriceConverter.convertToYemeni(saudiPrice: item["price"], exchangeRate: exchangeRate)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              PriceConverter.displayConvertedPrice(
                                  saudiPrice: item['total'],
                                  exchangeRate: exchangeRate),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails() {
    final address = order['delivery_address'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'تفاصيل العميل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              address['title'] ?? 'عنوان غير معروف',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  address['address'] ?? 'لم يتم تحديد العنوان',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
              ],
            ),
            if (address['notes'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'ملاحظات: ${address['notes']}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      NumberFormat currencyFormat, double exchanageRate, bool? isFree) {
    bool isFree2 = isFree ?? false;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
                'سعر السلعة',
                PriceConverter.displayConvertedPrice(
                    saudiPrice: order['subtotal'], exchangeRate: exchangeRate)),
            _buildSummaryRow(
                'رسوم التوصيل',
                isFree2
                    ? "التوصيل مجانا"
                    : PriceConverter.displayConvertedPrice(
                        saudiPrice: order['delivery_fee'] as double,
                        exchangeRate: exchangeRate)),
            if (order['discount'] > 0)
              _buildSummaryRow(
                  'تخفيض', '-${currencyFormat.format(order['discount'])}'),
            const Divider(height: 20),
            _buildSummaryRow(
              'المجموع',
              PriceConverter.displayConvertedPrice(
                  saudiPrice: order['total_amount'],
                  exchangeRate: exchangeRate),
              isTotal: true,
            ),
            const SizedBox(height: 10),
            Text(
              'طريقة الدفع: ${_getPaymentMethodText(order['payment_method'])}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
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

  Widget _buildPrintButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // ADDED: Clear cart when confirming order
          context.read<CartCubit>().clearCart();

          CustomSnackbar(
              context: context,
              snackBarType: SnackBarType.success,
              label: 'تم تأكد الطلب ');
          await Future.delayed(const Duration(milliseconds: 1500));

          // Close the entire app
          SystemNavigator.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          ' تأكد الطلب ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'preparing':
        return 'قيد التجهيز';
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
      case 'preparing':
        return Colors.blue;
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
      default:
        return method;
    }
  }
}
