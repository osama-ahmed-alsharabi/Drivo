import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_offer_service_provider_state.dart';

class FetchOfferServiceProviderCubit
    extends Cubit<FetchOfferServiceProviderState> {
  FetchOfferServiceProviderCubit() : super(FetchOfferServiceProviderInitial());
  List<OfferModel>? offerModel;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool hasLoaded = false;

  Future<void> fetchOfferServiceProvider() async {
    if (hasLoaded) {
      emit(FetchOfferServiceProviderLoading());
      try {
        String? userId = await SharedPreferencesService.getUserId();
        List<Map<String, dynamic>> offers = await _supabase
            .from('offers')
            .select()
            .eq('restaurant_id', userId!);
        offerModel = offers.map((e) => OfferModel.fromJson(e)).toList();
        await SharedPreferencesService.saveOffers(offers.length);
        emit(FetchOfferServiceProviderSuccessfully());
      } catch (e) {
        emit(FetchOfferServiceProviderFaulid(errorMessage: e.toString()));
      }
    }
  }

  Future<void> deleteOffer(OfferModel offer) async {
    emit(FetchOfferServiceProviderLoading());
    try {
      await _supabase.from('offers').delete().eq('id', offer.id!);

      // 2. (Optional) Delete the associated image from storage
      try {
        final imagePath = offer.imageUrl.split('/').last;
        await _supabase.storage.from('offers-bucket').remove([imagePath]);
      } catch (e) {
        // Silently fail if image deletion fails
        debugPrint('Failed to delete image: $e');
      }

      // 3. Refresh the offers list
      hasLoaded = true;
      await fetchOfferServiceProvider();
      hasLoaded = false;

      emit(FetchOfferServiceProviderDeletedSuccessfully());
    } catch (e) {
      emit(FetchOfferServiceProviderDeletedFauild(
        errorMessage: 'Failed to delete offer: ${e.toString()}',
      ));
    }
  }
}
