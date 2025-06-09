// import 'package:bloc/bloc.dart';
// import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
// import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// part 'fetch_client_products_state.dart';

// class FetchClientProductsCubit extends Cubit<FetchClientProductsState> {
//   FetchClientProductsCubit() : super(FetchClientProductsInitial());
//   final SupabaseClient _supabaseClient = Supabase.instance.client;
//   bool hasLoaded = false;
//   List<ProductModel> products = [];
//   fetchClientProducts() async {
//     if (hasLoaded) {
//       emit(FetchClientProductsLoading());
//       try {
//         // First get the current exchange rate
//         final exchangeResponse = await _supabaseClient
//             .from('exchange_rate')
//             .select('rate')
//             .order('created_at', ascending: false)
//             .limit(1)
//             .single();

//         final exchangeRate = (exchangeResponse['rate'] as num).toDouble();

//         // Then get products
//         final response = await _supabaseClient.from("products").select();

//         products = response.map<ProductModel>((e) {
//           return ProductModel.fromJson(e).copyWith(
//             exchangeRate: exchangeRate,
//           );
//         }).toList();

//         emit(FetchClientProductsSuccess());
//       } catch (e) {
//         emit(FetchClientProductsFaulier());
//       }
//     }

//     // try {
//     //   emit(FetchClientProductsLoading());
//     //   var respons = await _supabaseClient.from("products").select();
//     //   products = respons.map((e) => ProductModel.fromJson(e)).toList();
//     //   emit(FetchClientProductsSuccess());
//     // } catch (e) {
//     //   emit(FetchClientProductsFaulier());
//     // }
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_client_products_state.dart';

class FetchClientProductsCubit extends Cubit<FetchClientProductsState> {
  FetchClientProductsCubit() : super(FetchClientProductsInitial());
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool hasLoaded = false;
  List<ProductModel> products = [];

  Future<void> fetchClientProducts() async {
    if (hasLoaded) {
      emit(FetchClientProductsLoading());
      try {
        // 1. First get the current exchange rate
        final exchangeResponse = await _supabaseClient
            .from('exchange_rate')
            .select('rate')
            .order('created_at', ascending: false)
            .limit(1)
            .single();

        final exchangeRate = (exchangeResponse['rate'] as num).toDouble();

        // 2. Get all active restaurants (facilities where is_active = true)
        final activeRestaurants = await _supabaseClient
            .from('facilities')
            .select('id')
            .eq('is_active', true);

        if (activeRestaurants.isEmpty) {
          products = [];
          emit(FetchClientProductsSuccess());
          return;
        }

        // 3. Extract restaurant IDs as List<String>
        final restaurantIds =
            activeRestaurants.map((r) => r['id'].toString()).toList();

        // 4. Get products only from active restaurants
        final response = await _supabaseClient
            .from("products")
            .select()
            .inFilter('restaurant_id', restaurantIds); // Changed to inFilter

        products = response.map<ProductModel>((e) {
          return ProductModel.fromJson(e).copyWith(
            exchangeRate: exchangeRate,
          );
        }).toList();

        emit(FetchClientProductsSuccess());
        hasLoaded = false;
      } catch (e) {
        print('Error fetching products: $e');
        emit(FetchClientProductsFaulier());
      }
    }
  }
}
