import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/service_provider/first_page/data/model/facility_model.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'fetch_client_facilities_state.dart';

class FetchClientFacilitiesCubit extends Cubit<FetchClientFacilitiesState> {
  FetchClientFacilitiesCubit() : super(FetchClientFacilitiesInitial());
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool hasLoaded = false;

  fetchClientFacilities() async {
    if (hasLoaded) {
      try {
        emit(FetchClientFacilitiesLoading());
        var response = await _supabaseClient.from("facilities").select();
        List<FacilityModel> facilitiesModel =
            response.map((e) => FacilityModel.fromJson(e)).toList();

        emit(FetchClientFacilitiesSuccess(facilityModel: facilitiesModel));
      } catch (e) {
        emit(FetchClientFacilitiesFaulier());
      }
    }
  }
}
