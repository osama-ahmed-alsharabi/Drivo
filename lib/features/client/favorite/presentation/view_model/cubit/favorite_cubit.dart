import 'package:bloc/bloc.dart';
import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteInitial()) {
    loadFavorites();
  }
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  final DatabaseService _db = DatabaseService();

  Future<void> loadFavorites() async {
    emit(FavoriteLoading());
    try {
      final exchangeResponse = await _supabaseClient
          .from('exchange_rate')
          .select('rate')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final exchangeRate = (exchangeResponse['rate'] as num).toDouble();

      final products = await _db.getFavoriteProducts();
      emit(FavoriteLoaded(products, exchangeRate));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      final isFav = await _db.isFavorite(product.id!);
      if (isFav) {
        await _db.removeFavorite(product.id!);
      } else {
        await _db.insertFavorite(product);
      }
      await loadFavorites();
    }
  }

  Future<void> clearFavorites() async {
    await _db.clearFavorites();
    emit(FavoriteLoaded(const [], 1));
  }
}
