import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/dashboard/presentation/view/widgets/state_item_widget.dart';
import 'package:flutter/material.dart';

class StateCardProviderWidget extends StatelessWidget {
  const StateCardProviderWidget({super.key});

  Future<Map<String, int>> _loadData() async {
    final offersLength = await SharedPreferencesService.getOffers() ?? 0;
    final productLength = await SharedPreferencesService.getProducts() ?? 0;
    return {
      'offers': offersLength,
      'products': productLength,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadData(),
      builder: (context, snapshot) {
        final offersLength = snapshot.data?['offers'] ?? 0;
        final productLength = snapshot.data?['products'] ?? 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StateItemWidget(
                      title: 'العروض النشطة',
                      value: "$offersLength",
                      icon: Icons.local_offer,
                    ),
                    StateItemWidget(
                      title: 'المنتجات',
                      value: "$productLength",
                      icon: Icons.fastfood,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
