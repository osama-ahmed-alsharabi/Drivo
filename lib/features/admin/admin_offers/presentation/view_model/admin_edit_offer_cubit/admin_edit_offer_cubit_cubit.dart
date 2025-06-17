import 'dart:io';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_edit_offer_cubit_state.dart';

class AdminEditOfferCubitCubit extends Cubit<AdminEditOfferCubitState> {
  AdminEditOfferCubitCubit() : super(AdminEditOfferCubitInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> adminEditOffers({
    required OfferModel updatedOffer,
    File? imageFile,
  }) async {
    try {
      emit(AdminEditOfferCubitLoading());

      // Update image first if new image was selected
      if (imageFile != null) {
        final imagePath =
            'offer_${updatedOffer.id}_${DateTime.now().millisecondsSinceEpoch}';
        await _supabase.storage
            .from('offers-bucket')
            .upload(imagePath, imageFile);

        final imageUrl =
            _supabase.storage.from('offers-bucket').getPublicUrl(imagePath);

        updatedOffer = updatedOffer.copyWith(imageUrl: imageUrl);
      }

      // Update offer data
      await _supabase
          .from('offers')
          .update(updatedOffer.toJson(updatedOffer))
          .eq("id", updatedOffer.id!);

      emit(AdminEditOfferCubitSuccess());
    } catch (e) {
      emit(AdminEditOfferCubitFauler());
      rethrow;
    }
  }
}
