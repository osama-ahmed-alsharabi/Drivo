import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

part 'adding_offer_service_provider_state.dart';

class AddOfferCubit extends Cubit<AddingOfferServiceProviderState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  AddOfferCubit() : super(AddingOfferServiceProviderInitial());

  Future<void> addOffer({
    required OfferModel offer,
    required String imagePath,
  }) async {
    emit(AddingOfferServiceProviderLoading());

    try {
      // 1. Upload image to Supabase storage
      final file = File(imagePath);
      final fileBytes = await file.readAsBytes();
      final fileExt = extension(imagePath);
      final fileName = '${DateTime.now().toIso8601String()}$fileExt';
      final filePath = 'offers/$fileName';

      await supabaseClient.storage
          .from('offers-bucket')
          .uploadBinary(filePath, fileBytes);

      // 2. Get the public URL of the uploaded image
      final imageUrl =
          supabaseClient.storage.from('offers-bucket').getPublicUrl(filePath);

      // 3. Update offer with image URL
      final offerWithImage = offer.copyWith(imageUrl: imageUrl);

      // 4. Save offer to database using the toJson method
      final response = await supabaseClient
          .from('offers')
          .insert(offerWithImage.toJson(offerWithImage));

      emit(const AddingOfferServiceProviderSuccess('تم إضافة العرض بنجاح'));
    } catch (e) {
      log(e.toString());
      emit(AddingOfferServiceProviderFailure('حدث خطأ: ${e.toString()}'));
    }
  }
}
