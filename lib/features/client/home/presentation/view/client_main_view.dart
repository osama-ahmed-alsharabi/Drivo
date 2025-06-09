import 'package:drivo_app/features/client/home/presentation/view/widgets/category_secion_widget.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/offers_widget.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/product_grid_view_widget.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/category_cubit/category_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_offers/fetch_client_offer_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_products/fetch_client_products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ClientMainView extends StatelessWidget {
  const ClientMainView({super.key});

  Future<void> _handleRefresh(BuildContext context) async {
    // Refresh all data
    BlocProvider.of<FetchClientOfferCubit>(context).fetchClientOffers();
    BlocProvider.of<FetchClientOfferCubit>(context).hasLoaded = true;
    BlocProvider.of<CategoryCubit>(context).getCategory();
    BlocProvider.of<CategoryCubit>(context).hasLoaded = true;
    BlocProvider.of<FetchClientProductsCubit>(context).fetchClientProducts();
    BlocProvider.of<FetchClientProductsCubit>(context).hasLoaded = true;

    // You can add a small delay to ensure the refresh indicator shows properly
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () => _handleRefresh(context),
      color: Theme.of(context).primaryColor, // Use your theme color
      height: 100, // Adjust as needed
      animSpeedFactor: 1, // Adjust animation speed
      child: ListView(
        children: [
          const SizedBox(height: 10),
          BlocBuilder<FetchClientOfferCubit, FetchClientOfferState>(
            builder: (context, state) {
              if (state is FetchClientOfferSuccess) {
                return OffersWidget(
                  offerModel: state.offerModel,
                );
              } else if (state is FetchClientOfferFaulier) {
                return OffersWidget(
                  errorMessage: state.errorMessage,
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              if (state is CategorySuccess) {
                return CategorySecionWidget(
                  title: 'الأقسام الرئيسية',
                  categoryModel: state.categoryModel!,
                );
              } else {
                return const CategorySecionWidget(
                  title: 'الأقسام الرئيسية',
                  categoryModel: [],
                );
              }
            },
          ),
          BlocBuilder<FetchClientProductsCubit, FetchClientProductsState>(
            builder: (context, state) {
              return ProductGridViewWidget(
                productModel:
                    BlocProvider.of<FetchClientProductsCubit>(context).products,
              );
            },
          ),
        ],
      ),
    );
  }
}
