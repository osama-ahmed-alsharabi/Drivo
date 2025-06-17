// service_provider_profile_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'service_provider_profile_state.dart';

class ServiceProviderProfileCubit extends Cubit<ServiceProviderProfileState> {
  final SupabaseClient supabaseClient;

  ServiceProviderProfileCubit({required this.supabaseClient})
      : super(ServiceProviderProfileInitial());

  Future<void> fetchProfileData(String userId) async {
    emit(ServiceProviderProfileLoading());
    try {
      final response = await supabaseClient
          .from('facilities')
          .select()
          .eq('id', userId)
          .single();

      emit(ServiceProviderProfileLoaded(response));
    } catch (e) {
      emit(ServiceProviderProfileError(e.toString()));
    }
  }
}
