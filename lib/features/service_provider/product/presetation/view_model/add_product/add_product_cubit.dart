import 'dart:io';

import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit() : super(AddProductInitial());
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addProduct({
    required ProductModel product,
    required String imagePath,
  }) async {
    emit(AddProductLoading());
    try {
      // Upload image first
      final fileBytes = await File(imagePath).readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';

      await _supabase.storage
          .from('products')
          .uploadBinary(fileName, fileBytes);

      final imageUrl =
          _supabase.storage.from('products').getPublicUrl(fileName);

      // Then add product with image URL
      await _supabase.from('products').insert({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'is_available': product.isAvailable,
        'image_url': imageUrl,
        'restaurant_id': product.restaurantId,
        'created_at': DateTime.now().toIso8601String(),
      });

      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure(errorMessage: e.toString()));
    }
  }

  Future<void> updateProduct({
    required ProductModel product,
    String? imagePath,
  }) async {
    emit(AddProductLoading());
    try {
      String? imageUrl = product.imageUrl; // Preserve existing image URL

      // If new image is provided, upload it and update the URL
      if (imagePath != null) {
        final fileBytes = await File(imagePath).readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';

        await _supabase.storage
            .from('products')
            .uploadBinary(fileName, fileBytes,
                fileOptions: const FileOptions(
                  upsert: true,
                ));

        imageUrl = _supabase.storage.from('products').getPublicUrl(fileName);
      }

      // Prepare update data
      final updateData = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'is_available': product.isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only include image_url if we have a value
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }

      // Update product
      await _supabase.from('products').update(updateData).eq('id', product.id!);

      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure(errorMessage: e.toString()));
    }
  }
}
