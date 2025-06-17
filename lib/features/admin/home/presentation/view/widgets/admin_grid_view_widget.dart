import 'package:drivo_app/features/admin/admin_delivery/presentation/view/admin_deliveries_screen.dart';
import 'package:drivo_app/features/admin/admin_facilites/presentation/view/admin_fetch_facilities.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view/admin_offer_view.dart';
import 'package:drivo_app/features/admin/admin_order/presentation/view/admin_orders_screen.dart';
import 'package:drivo_app/features/admin/admin_reports/presentation/view/admin_report_view.dart';
import 'package:flutter/material.dart';

class AdminGridViewWidget extends StatelessWidget {
  const AdminGridViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (data[index] == "العروض") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminOfferView(),
                ),
              );
            } else if (data[index] == "المطاعم") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminFetchFacilities(),
                ),
              );
            } else if (data[index] == "الموصلين") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDeliveriesScreen(),
                ),
              );
            } else if (data[index] == "الطلبات") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminOrdersScreen(),
                ),
              );
            } else if (data[index] == "التقارير") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminReportView()),
              );
            }
          },
          child: Card(
            shadowColor: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data[index],
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const List<String> data = [
    "العروض",
    "المطاعم",
    "الطلبات",
    "الموصلين",
    "التقارير"
  ];
}
