import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view/widgets/add_product_page.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view/widgets/product_card_widget.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsSeviceProviderView extends StatefulWidget {
  const ProductsSeviceProviderView({super.key});

  @override
  State<ProductsSeviceProviderView> createState() =>
      _ProductsSeviceProviderViewState();
}

class _ProductsSeviceProviderViewState
    extends State<ProductsSeviceProviderView> {
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
    BlocProvider.of<FetchProductsServiceProviderCubit>(context).fetchProducts();
    BlocProvider.of<FetchProductsServiceProviderCubit>(context).hasLoaded =
        false;
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

  Future<bool> _checkFacilityActive() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('is_active')
        .eq('id', userId)
        .single();

    return response['is_active'] ?? false;
  }

  Future<bool> _checkFacilityLocation() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) return false;

    final response = await Supabase.instance.client
        .from('facilities')
        .select('latitude, longitude, address')
        .eq('id', userId)
        .single();

    return response['latitude'] != null &&
        response['longitude'] != null &&
        response['address'] != null;
  }

  void _showNotActiveSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('حسابك غير مفعل'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('المنتجات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final isActive = await _checkFacilityActive();
              if (!isActive) {
                _showNotActiveSnackBar(context);
                return;
              }

              final hasLocation = await _checkFacilityLocation();
              if (!hasLocation) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قم بإضافة منطقة من الإعدادات أولاً'),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductPage(),
                ),
              );
            },
          ),
        ],
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
                      itemCount: _categories.length + 1, // +1 for 'All' option
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
                return BlocConsumer<FetchProductsServiceProviderCubit,
                    FetchProductsState>(
                  listener: (context, state) {
                    if (state is FetchProductsDeleteSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف المنتج بنجاح')),
                      );
                      BlocProvider.of<FetchProductsServiceProviderCubit>(
                              context)
                          .hasLoaded = true;
                      BlocProvider.of<FetchProductsServiceProviderCubit>(
                              context)
                          .fetchProducts();
                      BlocProvider.of<FetchProductsServiceProviderCubit>(
                              context)
                          .hasLoaded = false;
                    } else if (state is FetchProductsDeleteFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is FetchProductsLoading) {
                      return Center(
                          child: Image.asset('assets/images/logo_waiting.gif'));
                    } else if (BlocProvider.of<
                                FetchProductsServiceProviderCubit>(context)
                            .products
                            ?.isEmpty ??
                        true) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child:
                                Lottie.asset(AppImages.foodPlaceholderLottie),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "لا توجد منتجات بعد، قم بإضافة منتج",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                      );
                    }
                    return state is FetchProductsFailure
                        ? Center(
                            child: Text(
                              state.errorMessage,
                              style: const TextStyle(color: Colors.black),
                            ),
                          )
                        : LiquidPullToRefresh(
                            onRefresh: () async {
                              BlocProvider.of<
                                          FetchProductsServiceProviderCubit>(
                                      context)
                                  .hasLoaded = true;
                              await BlocProvider.of<
                                          FetchProductsServiceProviderCubit>(
                                      context)
                                  .fetchProducts();
                              BlocProvider.of<
                                          FetchProductsServiceProviderCubit>(
                                      context)
                                  .hasLoaded = false;
                            },
                            child: _buildProductsList(context));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    final products =
        BlocProvider.of<FetchProductsServiceProviderCubit>(context).products;
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          product: product,
        );
      },
    );
  }
}
