import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/client/favorite/presentation/view_model/cubit/favorite_cubit.dart';
import 'package:drivo_app/features/client/home/presentation/view/widgets/products_detial_view.dart';
import 'package:drivo_app/features/client/home/presentation/view_model/fetch_client_products/fetch_client_products_cubit.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final List<String> _categories = [
    'الشبس والصوصات',
    'بروست',
    'ايسكريم',
    'الأرز',
    'الشوربة',
    'المقبلات',
    'شاورما',
    'مشكل فرن',
    'اللحوم',
    'فاهيتا وزنجر',
    'القلابة',
    'مأكولات هندية',
    'مأكولات بحرية',
    'برجر',
    'مشاوي',
    'سلطات',
    'الفتة',
    'باستا ومكرونة',
    'بيتزا',
    'مشروبات',
    'مشروبات ساخنة',
    'أطباق حلى',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetchClientProductsCubit>(context).fetchClientProducts();
    BlocProvider.of<FetchClientProductsCubit>(context).hasLoaded = false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel>? products) {
    if (products == null) return [];

    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'الكل' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: () async {
        BlocProvider.of<FetchClientProductsCubit>(context).hasLoaded = true;
        BlocProvider.of<FetchClientProductsCubit>(context)
            .fetchClientProducts();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('ابحث عن وجبة'),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Search and Filter Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Category Filter
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _categories.length + 1, // +1 for 'All' option
                        itemBuilder: (context, index) {
                          final category =
                              index == 0 ? 'الكل' : _categories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : 'الكل';
                                });
                              },
                              selectedColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Products List
              Expanded(
                child: Builder(builder: (context) {
                  return BlocConsumer<FetchClientProductsCubit,
                      FetchClientProductsState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is FetchClientProductsLoading) {
                        return Center(
                            child:
                                Image.asset('assets/images/logo_waiting.gif'));
                      } else if (BlocProvider.of<FetchClientProductsCubit>(
                              context)
                          .products
                          .isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child:
                                  Lottie.asset(AppImages.foodPlaceholderLottie),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "لا توجد منتجات بعد",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        );
                      }
                      return state is FetchClientProductsFaulier
                          ? const Center(
                              child: Text(
                                "تأكد من الاتصال بالانترنت",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : _buildProductsList(context);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, {isFavoriteView = false}) {
    final products =
        BlocProvider.of<FetchClientProductsCubit>(context).products;
    final filteredProducts = _filterProducts(products);

    if (filteredProducts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(AppImages.foodPlaceholderLottie),
          ),
          const SizedBox(height: 30),
          const Text(
            "لا توجد منتجات تطابق البحث",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(
                          product: filteredProducts[index])));
            },
            child: Card(
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
                          child: filteredProducts[index].imageUrl == null
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
                                    imageUrl: filteredProducts[index].imageUrl!,
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
                                    .isFavorite(filteredProducts[index].id!),
                                builder: (context, snapshot) {
                                  final isFavorite = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: () => cubit.toggleFavorite(
                                        filteredProducts[index]),
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

// Add this to handle removal from favorites in the details screen
                        if (isFavoriteView)
                          Positioned(
                            top: 3,
                            left: 3,
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<FavoriteCubit>()
                                    .toggleFavorite(filteredProducts[index]);
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
                          filteredProducts[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${PriceConverter.formatNumberWithCommas(PriceConverter.convertToYemeni(
                            saudiPrice: filteredProducts[index].price,
                            exchangeRate:
                                filteredProducts[index].exchangeRate ?? 1,
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
