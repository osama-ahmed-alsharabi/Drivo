import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_client_offer_state.dart';

class FetchClientOfferCubit extends Cubit<FetchClientOfferState> {
  FetchClientOfferCubit() : super(FetchClientOfferInitial());
  SupabaseClient supabaseClient = Supabase.instance.client;
  bool hasLoaded = false;
  fetchClientOffers() async {
    if (hasLoaded) {
      try {
        emit(FetchClientOfferLoading());
        final activeRestaurants = await supabaseClient
            .from('facilities')
            .select('id')
            .eq('is_active', true);
        final restaurantIds =
            activeRestaurants.map((r) => r['id'].toString()).toList();
        var response = await supabaseClient
            .from("offers")
            .select()
            .eq("is_active", true)
            .inFilter('restaurant_id', restaurantIds);
        List<OfferModel> offerModel =
            response.map((e) => OfferModel.fromJson(e)).toList();
        emit(FetchClientOfferSuccess(offerModel: offerModel));
      } catch (e) {
        emit(const FetchClientOfferFaulier(
            errorMessage: "تأكد من الاتصال بالانترنت"));
      }
    }
  }
}
