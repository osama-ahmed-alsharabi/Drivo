// features/restaurants/list/presentation/cubit/restaurant_list_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'restaurant_list_state.dart';

class RestaurantListCubit extends Cubit<RestaurantListState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  RestaurantListCubit() : super(RestaurantListInitial());
  List<Map<String, dynamic>> _allRestaurants = [];

  void filterRestaurants(String query) {
    if (query.isEmpty) {
      emit(RestaurantListLoaded(restaurants: _allRestaurants));
      return;
    }

    final filtered = _allRestaurants.where((restaurant) {
      final name = restaurant['facility_name']?.toString().toLowerCase() ?? '';
      final category =
          restaurant['facility_category']?.toString().toLowerCase() ?? '';
      final directorate =
          restaurant['directorate']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) ||
          category.contains(searchLower) ||
          directorate.contains(searchLower);
    }).toList();

    emit(filtered.isEmpty
        ? RestaurantListEmpty()
        : RestaurantListLoaded(restaurants: filtered));
  }

  Future<void> fetchRestaurants() async {
    emit(RestaurantListLoading());
    try {
      final response =
          await Supabase.instance.client.from('facilities').select('''
          *,
          ratings:ratings(
            rating
          )
        ''').eq('facility_category', 'restaurant').eq("is_active", true);

      _allRestaurants =
          List<Map<String, dynamic>>.from(response).map((restaurant) {
        // Calculate average rating
        final ratings =
            List<Map<String, dynamic>>.from(restaurant['ratings'] ?? []);
        final totalRatings = ratings.length;
        final averageRating = totalRatings > 0
            ? ratings.map((r) => r['rating'] as num).reduce((a, b) => a + b) /
                totalRatings
            : 0.0;

        return {
          ...restaurant,
          'average_rating': averageRating,
          'total_ratings': totalRatings,
        };
      }).toList();

      if (_allRestaurants.isEmpty) {
        emit(RestaurantListEmpty());
      } else {
        emit(RestaurantListLoaded(restaurants: _allRestaurants));
      }
    } catch (e) {
      emit(RestaurantListError(message: e.toString()));
    }
  }
}
