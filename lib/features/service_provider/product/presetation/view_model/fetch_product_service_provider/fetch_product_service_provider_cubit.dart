import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FetchProductsServiceProviderCubit extends Cubit<FetchProductsState> {
  FetchProductsServiceProviderCubit() : super(FetchProductsInitial());

  List<ProductModel>? products;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool hasLoaded = false;

  Future<void> fetchProducts() async {
    if (hasLoaded) {
      emit(FetchProductsLoading());
      try {
        String? userId = await SharedPreferencesService.getUserId();

        final response = await _supabase
            .from('products')
            .select()
            .eq('restaurant_id', userId!)
            .order('created_at', ascending: false);

        products = (response as List)
            .map((product) => ProductModel.fromJson(product))
            .toList();
        await SharedPreferencesService.saveProducts(products?.length ?? 0);

        emit(FetchProductsSuccess());
      } catch (e) {
        emit(FetchProductsFailure(errorMessage: e.toString()));
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(FetchProductsLoading());
    try {
      await _supabase.from('products').delete().eq('id', productId);
      emit(FetchProductsDeleteSuccess());
    } catch (e) {
      emit(FetchProductsDeleteFailure(errorMessage: e.toString()));
    }
  }
}
