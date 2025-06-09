import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/client/favorite/presentation/view_model/cubit/favorite_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/product_grid_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    BlocProvider.of<FavoriteCubit>(context).loadFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      builder: (context, state) {
        if (state is FavoriteInitial || state is FavoriteLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FavoriteError) {
          return Center(child: Text(state.message));
        } else if (state is FavoriteLoaded) {
          if (state.favorites.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Lottie.asset(AppImages.favoriteLottie),
                ),
              ],
            );
          } else {
            return ProductGridViewWidget(
              productModel: state.favorites,
              exchange: state.exchange,
              isFavoriteView: true,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
