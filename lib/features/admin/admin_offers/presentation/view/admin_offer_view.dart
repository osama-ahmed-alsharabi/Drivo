import 'package:drivo_app/features/admin/admin_offers/presentation/view/admin_fetch_offer_bloc_builder_widget.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view_model/admin_fetch_offer_cubit/admin_fetch_offers_cubit.dart';
import 'package:drivo_app/features/admin/home/presentation/view/widgets/admin_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminOfferView extends StatelessWidget {
  const AdminOfferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => AdminFetchOffersCubit()..hasLoaded = true,
      child: const Column(
        children: [
          AdminAppBarWidget(text: "العروض"),
          AdminFetchOfferBlocBuilderWidget(),
        ],
      ),
    ));
  }
}
