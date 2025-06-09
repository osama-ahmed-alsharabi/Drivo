import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/widgets/add_offer_page.dart';
import 'package:drivo_app/features/service_provider/dashboard/presentation/view/widgets/quick_action_button_widget.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view/widgets/add_product_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({super.key});

  Future<bool> _checkFacilityActive() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('is_active')
        .eq('id', userId)
        .single();

    return response['is_active'] ?? false;
  }

  Future<bool> _checkFacilityLocation() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('latitude, longitude, address')
        .eq('id', userId)
        .single();

    return response['latitude'] != null &&
        response['longitude'] != null &&
        response['address'] != null;
  }

  void _showNotActiveSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('حسابك غير مفعل'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إجراءات سريعة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickActionButtonWidget(
                  label: 'إضافة عرض',
                  icon: Icons.add,
                  onTap: () async {
                    final isActive = await _checkFacilityActive();
                    if (!isActive) {
                      _showNotActiveSnackBar(context);
                      return;
                    }

                    final hasLocation = await _checkFacilityLocation();
                    if (!hasLocation) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('قم بإضافة منطقة من الإعدادات أولاً'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddOfferServiceProviderPage(),
                      ),
                    );
                  },
                ),
                QuickActionButtonWidget(
                  label: 'إضافة منتج',
                  icon: Icons.add,
                  onTap: () async {
                    final isActive = await _checkFacilityActive();
                    if (!isActive) {
                      _showNotActiveSnackBar(context);
                      return;
                    }

                    final hasLocation = await _checkFacilityLocation();
                    if (!hasLocation) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('قم بإضافة منطقة من الإعدادات أولاً'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductPage(),
                      ),
                    );
                  },
                ),
                QuickActionButtonWidget(
                  label: 'الطلبات',
                  icon: Icons.list_alt,
                  onTap: () async {
                    final isActive = await _checkFacilityActive();
                    if (!isActive) {
                      _showNotActiveSnackBar(context);
                      return;
                    }

                    final restaurantId =
                        await SharedPreferencesService.getUserId();
                    if (restaurantId == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantOrdersPage(restaurantId: restaurantId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantOrdersPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantOrdersPage({super.key, required this.restaurantId});

  @override
  State<RestaurantOrdersPage> createState() => _RestaurantOrdersPageState();
}

class _RestaurantOrdersPageState extends State<RestaurantOrdersPage> {
  List<Order> _orders = [];
  bool _isLoading = true;
  double _exchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate().then((_) => _fetchOrders());
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await Supabase.instance.client
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      setState(() {
        _exchangeRate = (response['rate'] as num).toDouble();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load exchange rate: $e')),
      );
      setState(() {
        _exchangeRate = 1.0;
      });
    }
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final filteredOrders = (response as List).where((order) {
        final items = order['items'] as List;
        return items
            .any((item) => item['restaurant_id'] == widget.restaurantId);
      }).toList();

      final orders = filteredOrders.map((orderJson) {
        final allItems = (orderJson['items'] as List)
            .map((item) => OrderItem(
                  productId: item['product_id'] as String,
                  productName: item['name'] as String,
                  restaurantId: item['restaurant_id'] as String,
                  quantity: item['quantity'] as int,
                  unitPrice: (item['price'] as num).toDouble(),
                ))
            .toList();

        final restaurantItems = allItems
            .where(
              (item) => item.restaurantId == widget.restaurantId,
            )
            .toList();

        final deliveryAddressJson =
            orderJson['delivery_address'] as Map<String, dynamic>;
        final deliveryAddress = DeliveryAddress(
          id: deliveryAddressJson['id'] as int,
          title: deliveryAddressJson['title'] as String,
          address: deliveryAddressJson['address'] as String,
          latitude: (deliveryAddressJson['latitude'] as num).toDouble(),
          longitude: (deliveryAddressJson['longitude'] as num).toDouble(),
        );

        return Order(
          id: orderJson['id'] as String,
          orderNumber: orderJson['order_number'] as String,
          status: OrderStatusX.fromString(orderJson['order_status'] as String),
          createdAt: DateTime.parse(orderJson['created_at'] as String),
          updatedAt: orderJson['updated_at'] != null
              ? DateTime.parse(orderJson['updated_at'] as String)
              : null,
          subtotal: (orderJson['subtotal'] as num).toDouble(),
          deliveryFee: (orderJson['delivery_fee'] as num).toDouble(),
          discount: (orderJson['discount'] as num).toDouble(),
          totalAmount: (orderJson['total_amount'] as num).toDouble(),
          paymentMethod:
              PaymentMethodX.fromString(orderJson['payment_method'] as String),
          paymentStatus: orderJson['payment_status'] as String?,
          deliveryAddress: deliveryAddress,
          items: restaurantItems,
          customerNotes: orderJson['customer_notes'] as String?,
          isFreeDelivery: orderJson['is_free_delivery'] ?? false,
        );
      }).toList();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المطعم'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    order.status.displayText,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: order.status.color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('التاريخ: ${_formatDate(order.createdAt)}'),
            const SizedBox(height: 8),
            Text('العنوان: ${order.deliveryAddress.address}'),
            const SizedBox(height: 8),
            Text('عدد العناصر: ${order.items.length}'),
            const SizedBox(height: 8),
            Text('المجموع: ${PriceConverter.displayConvertedPrice(
              saudiPrice: order.totalAmount,
              exchangeRate: _exchangeRate,
              showBoth: true,
            )}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showOrderDetails(order),
              child: const Text('عرض التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الحالة: ${order.status.displayText}'),
              Text('طريقة الدفع: ${order.paymentMethod.displayText}'),
              const SizedBox(height: 10),
              const Text('العناصر:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(item.productName),
                    subtitle: Text(
                        '${item.quantity} × ${PriceConverter.displayConvertedPrice(
                      saudiPrice: item.unitPrice,
                      exchangeRate: _exchangeRate,
                    )}'),
                  )),
              const SizedBox(height: 10),
              const Text('العنوان:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(order.deliveryAddress.address),
              if (order.customerNotes != null) ...[
                const SizedBox(height: 10),
                const Text('ملاحظات العميل:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.customerNotes!),
              ],
              const SizedBox(height: 10),
              const Text('الفاتورة:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPriceRow('المجموع الفرعي:', order.subtotal),
              _buildPriceRow('رسوم التوصيل:', order.deliveryFee),
              _buildPriceRow('الخصم:', order.discount),
              const Divider(),
              _buildPriceRow('المجموع الكلي:', order.totalAmount,
                  isTotal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double saudiPrice,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Expanded(
          child: Text(
            PriceConverter.displayConvertedPrice(
              saudiPrice: saudiPrice,
              exchangeRate: _exchangeRate,
            ),
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class PriceConverter {
  static final _formatter = NumberFormat('#,###.##');

  static double convertToYemeni({
    required double saudiPrice,
    required double exchangeRate,
  }) {
    return saudiPrice * exchangeRate;
  }

  static String displayConvertedPrice({
    required double saudiPrice,
    required double exchangeRate,
    bool showBoth = false,
  }) {
    final yemeniPrice = convertToYemeni(
      saudiPrice: saudiPrice,
      exchangeRate: exchangeRate,
    );

    if (showBoth) {
      return '${_formatter.format(saudiPrice)} ر.س (≈ ${_formatter.format(yemeniPrice)} ريال يمني)';
    } else {
      return '${_formatter.format(yemeniPrice)} ريال يمني';
    }
  }

  static String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###.##');
    return formatter.format(number);
  }
}
