import 'package:drivo_app/features/service_provider/home_provider/presentation/view_model/ServiceProvider/service_provider_state.dart';
import 'package:drivo_app/features/service_provider/home_provider/presentation/views/service_provider_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  final SupabaseClient supabaseClient;

  ServiceProviderCubit(this.supabaseClient) : super(ServiceProviderInitial());

  Future<void> fetchServiceProvider(String userId) async {
    emit(ServiceProviderLoading());
    try {
      final response = await supabaseClient
          .from('facilities')
          .select()
          .eq('id', userId)
          .single();

      final provider = ServiceProviderModel.fromJson(response);
      emit(ServiceProviderLoaded(provider));
    } on PostgrestException catch (e) {
      emit(ServiceProviderError(e.message));
    } catch (e) {
      emit(ServiceProviderError('Failed to fetch service provider'));
    }
  }

  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    emit(ServiceProviderLoading());
    try {
      await supabaseClient.from('facilities').update({
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Refresh the data
      await fetchServiceProvider(userId);
    } on PostgrestException catch (e) {
      emit(ServiceProviderError(e.message));
    } catch (e) {
      emit(ServiceProviderError('Failed to update location'));
    }
  }
}
