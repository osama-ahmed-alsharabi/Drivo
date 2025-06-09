import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/fetch_offers_service_provider_view.dart';
import 'package:drivo_app/features/service_provider/dashboard/presentation/view/dashboard_view.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view/product_provider_view.dart';
import 'package:drivo_app/features/service_provider/profile_provider/Presentation/view/profile_provider_view.dart';
import 'package:flutter/material.dart';

class HomeProviderView extends StatefulWidget {
  const HomeProviderView({super.key});

  @override
  State<HomeProviderView> createState() => _HomeProviderViewState();
}

class _HomeProviderViewState extends State<HomeProviderView> {
  int _currentIndex = 3;
  final List<Widget> _pages = [
    const ServiceProviderProfileScreen(),
    const ProductsSeviceProviderView(),
    const FetchOffersServiceProviderView(),
    const DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.settings, size: 30, color: Colors.black),
          Icon(Icons.fastfood, size: 30, color: Colors.black),
          Icon(Icons.local_offer, size: 30, color: Colors.black),
          Icon(Icons.dashboard, size: 30, color: Colors.black),
        ],
        color: Colors.white,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
