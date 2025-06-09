import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/features/client/favorite/presentation/view_model/cubit/favorite_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/products_detial_view.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductGridViewWidget extends StatelessWidget {
  final List<ProductModel> productModel;
  final bool isFavoriteView;
  final double? exchange;
  const ProductGridViewWidget(
      {super.key,
      required this.productModel,
      this.isFavoriteView = false,
      this.exchange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: isFavoriteView ? null : const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: productModel.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: productModel[index])));
            },
            child: Card(
              shadowColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: productModel[index].imageUrl == null
                              ? const Center(
                                  child: Icon(
                                    Icons.shopping_bag,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: productModel[index].imageUrl!,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                        Icons.error,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 3,
                          right: 3,
                          child: BlocBuilder<FavoriteCubit, FavoriteState>(
                            builder: (context, state) {
                              final cubit = context.read<FavoriteCubit>();
                              return FutureBuilder<bool>(
                                future: DatabaseService()
                                    .isFavorite(productModel[index].id!),
                                builder: (context, snapshot) {
                                  final isFavorite = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: () => cubit
                                        .toggleFavorite(productModel[index]),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.withOpacity(0.8),
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (isFavoriteView)
                          Positioned(
                            top: 3,
                            left: 3,
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<FavoriteCubit>()
                                    .toggleFavorite(productModel[index]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.8),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productModel[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${PriceConverter.formatNumberWithCommas(PriceConverter.convertToYemeni(
                            saudiPrice: productModel[index].price,
                            exchangeRate: productModel[index].exchangeRate ??
                                exchange ??
                                1,
                          ))} ر.ي',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
