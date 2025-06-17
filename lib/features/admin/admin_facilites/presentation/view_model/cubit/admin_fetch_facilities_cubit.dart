// features/admin/admin_facilites/presentation/view_model/cubit/admin_fetch_facilities_cubit.dart
import 'package:drivo_app/features/admin/admin_facilites/presentation/view_model/cubit/admin_fetch_facilities_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFetchFacilitiesCubit extends Cubit<AdminFetchFacilitiesState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _allRestaurants = [];

  AdminFetchFacilitiesCubit() : super(AdminFetchFacilitiesInitail());

  void filterRestaurants(String query) {
    if (query.isEmpty) {
      emit(AdminFetchFacilitiesLoaded(restaurants: _allRestaurants));
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
        : AdminFetchFacilitiesLoaded(restaurants: filtered));
  }

  Future<void> fetchRestaurants() async {
    emit(AdminFetchFacilitiesLoading());
    try {
      final response = await supabaseClient.from('facilities').select('''
          *,
          ratings:ratings(
            rating
          )
        ''').eq('facility_category', 'restaurant');

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
        emit(AdminFetchFacilitiesLoaded(restaurants: _allRestaurants));
      }
    } catch (e) {
      emit(AdminFetchFacilitiesError(message: e.toString()));
    }
  }

  Future<void> toggleRestaurantStatus(
      String restaurantId, bool currentStatus) async {
    try {
      final updatedStatus = !currentStatus;

      await supabaseClient
          .from('facilities')
          .update({'is_active': updatedStatus}).eq('id', restaurantId);

      // Update local state
      final updatedIndex =
          _allRestaurants.indexWhere((r) => r['id'] == restaurantId);
      if (updatedIndex != -1) {
        _allRestaurants[updatedIndex]['is_active'] = updatedStatus;
        emit(RestaurantStatusUpdated(
            updatedRestaurant: _allRestaurants[updatedIndex]));
        emit(AdminFetchFacilitiesLoaded(restaurants: _allRestaurants));
      }
    } catch (e) {
      emit(AdminFetchFacilitiesError(
          message: 'Failed to update status: ${e.toString()}'));
    }
  }
}
