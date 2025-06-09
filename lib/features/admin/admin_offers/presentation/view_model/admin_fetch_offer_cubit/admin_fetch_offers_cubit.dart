import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_fetch_offers_state.dart';

class AdminFetchOffersCubit extends Cubit<AdminFetchOffersState> {
  AdminFetchOffersCubit() : super(AdminFetchOffersInitial());

  List<OfferModel>? offerModel;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool hasLoaded = false;

  Future<void> adminFetchOffers() async {
    emit(AdminFetchOffersLoading());
    try {
      final response = await _supabase.from('offers').select();
      offerModel =
          (response as List).map((e) => OfferModel.fromJson(e)).toList();
      emit(AdminFetchOffersSuccess());
    } catch (e) {
      emit(AdminFetchOffersFauiler(errorMessage: e.toString()));
    }
  }

  Future<void> deleteOffer(OfferModel offer) async {
    emit(AdminFetchOffersLoading());
    try {
      await _supabase.from('offers').delete().eq('id', offer.id!);

      try {
        final imagePath = offer.imageUrl.split('/').last;
        await _supabase.storage.from('offers-bucket').remove([imagePath]);
      } catch (e) {
        debugPrint('Failed to delete image: $e');
      }

      hasLoaded = true;
      await adminFetchOffers();
      emit(AdminFetchOfferDeletedSccess());
    } catch (e) {
      emit(AdminFetchOffersDeletedFauiler(
        errorMessage: 'Failed to delete offer: ${e.toString()}',
      ));
    }
  }
}
