import 'package:drivo_app/features/service_provider/home_provider/data/model/product_model.dart';
import 'package:drivo_app/features/service_provider/home_provider/presentation/view_model/product_provider_cubit/product_provider_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsProviderCubit extends Cubit<ProductsProviderState> {
  final SupabaseClient supabaseClient;

  ProductsProviderCubit(this.supabaseClient) : super(ProductsProviderInitial());

  Future<void> fetchProducts(String restaurantId) async {
    emit(ProductsProviderLoading());
    try {
      final response = await supabaseClient
          .from('products')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      final products =
          response.map((json) => ProductModel.fromJson(json)).toList();
      emit(ProductsProviderLoaded(products));
    } on PostgrestException catch (e) {
      emit(ProductsProviderError(e.message));
    } catch (e) {
      emit(ProductsProviderError('Failed to fetch products'));
    }
  }

  Future<void> addProduct({
    required String restaurantId,
    required String name,
    required double price,
    required String? imageUrl,
    String? description,
    String? category,
  }) async {
    emit(ProductsProviderLoading());
    try {
      await supabaseClient.from('products').insert({
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
      });

      await fetchProducts(restaurantId);
    } on PostgrestException catch (e) {
      emit(ProductsProviderError(e.message));
    } catch (e) {
      emit(ProductsProviderError('Failed to add product'));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    emit(ProductsProviderLoading());
    try {
      await supabaseClient.from('products').update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'image_url': product.imageUrl,
        'is_available': product.isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', product.id);

      await fetchProducts(product.restaurantId);
    } on PostgrestException catch (e) {
      emit(ProductsProviderError(e.message));
    } catch (e) {
      emit(ProductsProviderError('Failed to update product'));
    }
  }

  Future<void> deleteProduct(String productId, String restaurantId) async {
    emit(ProductsProviderLoading());
    try {
      await supabaseClient.from('products').delete().eq('id', productId);
      await fetchProducts(restaurantId);
    } on PostgrestException catch (e) {
      emit(ProductsProviderError(e.message));
    } catch (e) {
      emit(ProductsProviderError('Failed to delete product'));
    }
  }
}
