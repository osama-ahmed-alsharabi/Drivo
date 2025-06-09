import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/client/cart/presentation/view/cart_view.dart';
import 'package:drivo_app/features/client/favorite/presentation/view/favorite_view.dart';
import 'package:drivo_app/features/client/home/presentation/view/client_main_view.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/category_cubit/category_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_offers/fetch_client_offer_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_products/fetch_client_products_cubit.dart';
import 'package:drivo_app/features/client/profile/presentation/views/profile_view.dart';
import 'package:drivo_app/features/client/search/presentation/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  int _selectedIndex = 4;

  final List<Widget> _pages = [
    const ProfilePage(),
    const FavoritesPage(),
    const CartPage(),
    const SearchView(),
    const ClientMainView(),
  ];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetchClientOfferCubit>(context).fetchClientOffers();
    BlocProvider.of<FetchClientOfferCubit>(context).hasLoaded = false;
    BlocProvider.of<CategoryCubit>(context).getCategory();
    BlocProvider.of<CategoryCubit>(context).hasLoaded = false;
    BlocProvider.of<FetchClientProductsCubit>(context).fetchClientProducts();
    BlocProvider.of<FetchClientProductsCubit>(context).hasLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: SvgPicture.asset(
          AppImages.logoSvg,
          height: MediaQuery.sizeOf(context).height * 0.07,
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        items: const [
          Icon(Icons.person, size: 30),
          Icon(Icons.favorite, size: 30),
          Icon(Icons.shopping_cart, size: 30),
          Icon(Icons.search, size: 30),
          Icon(Icons.home, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
