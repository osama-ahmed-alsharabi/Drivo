import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/profile/presentation/views/user_order_list_page.dart';
import 'package:flutter/material.dart';

class ClientOrderSection extends StatelessWidget {
  const ClientOrderSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              "طلباتي",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to orders page
                  await SharedPreferencesService.getUserId();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserOrdersListPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("عرض جميع الطلبات"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStateItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final String title;
  const OrderStateItem({
    super.key,
    required this.icon,
    required this.count,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
