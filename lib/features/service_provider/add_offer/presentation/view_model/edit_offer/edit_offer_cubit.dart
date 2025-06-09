// features/service_provider/edit_offer/presentation/view_model/edit_offer_cubit.dart

import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

part 'edit_offer_state.dart';

class EditOfferCubit extends Cubit<EditOfferState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  EditOfferCubit() : super(EditOfferInitial());

  Future<void> editOffer({
    required OfferModel offer,
    String? imagePath,
  }) async {
    emit(EditOfferLoading());

    try {
      String? imageUrl = offer.imageUrl;

      // If a new image was selected, upload it
      if (imagePath != null) {
        final file = File(imagePath);
        final fileBytes = await file.readAsBytes();
        final fileExt = extension(imagePath);
        final fileName = '${DateTime.now().toIso8601String()}$fileExt';
        final filePath = 'offers/$fileName';

        await supabaseClient.storage
            .from('offers-bucket')
            .uploadBinary(filePath, fileBytes);

        imageUrl =
            supabaseClient.storage.from('offers-bucket').getPublicUrl(filePath);
      }

      // Update offer with new data
      final updatedOffer = offer.copyWith(
        imageUrl: imageUrl,
        isActive: offer.isActive,
        endDate: offer.endDate,
      );

      // Update offer in database
      await supabaseClient
          .from('offers')
          .update(updatedOffer.toJson(updatedOffer));

      emit(const EditOfferSuccess('تم تحديث العرض بنجاح'));
    } catch (e) {
      log(e.toString());
      emit(EditOfferFailure('حدث خطأ: ${e.toString()}'));
    }
  }
}
