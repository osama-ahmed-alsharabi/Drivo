import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/cart/data/model/order_model.dart';
import 'package:drivo_app/features/client/profile/presentation/view_model/cubit/user_order_cubit.dart';
import 'package:drivo_app/features/client/profile/presentation/view_model/cubit/user_order_state.dart';
import 'package:drivo_app/features/client/profile/presentation/views/user_order_detail_page.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOrdersListPage extends StatefulWidget {
  const UserOrdersListPage({super.key});

  @override
  State<UserOrdersListPage> createState() => _UserOrdersListPageState();
}

class _UserOrdersListPageState extends State<UserOrdersListPage> {
  double _exchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    // Initialize date formatting for Arabic locale
    initializeDateFormatting('ar').then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final userId = await SharedPreferencesService.getUserId();
        if (userId != null) {
          context.read<UserOrdersCubit>().fetchOrders(userId);
        }
      });
    });
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await Supabase.instance.client
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        setState(() {
          _exchangeRate = (response[0]['rate'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching exchange rate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('طلباتي'),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return BlocBuilder<UserOrdersCubit, UserOrdersState>(
          builder: (context, state) {
            if (state is UserOrdersInitial || state is UserOrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserOrdersError) {
              return Center(child: Text(state.message));
            } else if (state is UserOrdersLoaded) {
              return _buildOrdersList(context, state.orders);
            }
            return Container();
          },
        );
      }),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد طلبات سابقة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LiquidPullToRefresh(
      onRefresh: () async {
        final userId = await SharedPreferencesService.getUserId();
        if (userId != null) {
          context.read<UserOrdersCubit>().fetchOrders(userId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: order,
              exchangeRate: _exchangeRate,
              onTap: () {
                // In the parent widget (where you navigate to this page), update the navigation call:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserOrderDetailsPage(
                      order: order,
                      exchangeRate: _exchangeRate,
                    ),
                  ),
                ).then((confirmed) async {
                  if (confirmed == true) {
                    // Refresh orders if needed
                    final userId = await SharedPreferencesService.getUserId();
                    if (userId != null) {
                      context.read<UserOrdersCubit>().fetchOrders(userId);
                    }
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final double exchangeRate;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.exchangeRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'ar');
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', locale: 'ar');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.displayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(order.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} منتج',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text(
                      //   currencyFormat.format(order.totalAmount),
                      //   style: const TextStyle(

                      //   ),
                      // ),
                      Text(
                        '≈ ${_convertToYemeni(order.totalAmount, exchangeRate)} ريال يمني',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _convertToYemeni(double saudiPrice, double exchangeRate) {
    final yemeniPrice = saudiPrice * exchangeRate;
    final formatter = NumberFormat('#,###.##');
    return formatter.format(yemeniPrice);
  }
}
