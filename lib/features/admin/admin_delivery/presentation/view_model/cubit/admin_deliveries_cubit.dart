// features/admin/deliveries/presentation/view_model/cubit/admin_deliveries_cubit.dart
import 'package:drivo_app/features/admin/admin_delivery/presentation/view_model/cubit/admin_deliveries_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDeliveriesCubit extends Cubit<AdminDeliveriesState> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _allDeliveries = [];

  AdminDeliveriesCubit() : super(AdminDeliveriesInitial());

  void filterDeliveries(String query) {
    if (query.isEmpty) {
      emit(AdminDeliveriesLoaded(deliveries: _allDeliveries));
      return;
    }

    final filtered = _allDeliveries.where((delivery) {
      final name = delivery['user_name']?.toString().toLowerCase() ?? '';
      final phone = delivery['phone_number']?.toString().toLowerCase() ?? '';
      final directorate =
          delivery['directorate']?.toString().toLowerCase() ?? '';
      final email = delivery['email']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) ||
          phone.contains(searchLower) ||
          directorate.contains(searchLower) ||
          email.contains(searchLower);
    }).toList();

    emit(filtered.isEmpty
        ? DeliveriesListEmpty()
        : AdminDeliveriesLoaded(deliveries: filtered));
  }

  Future<void> fetchDeliveries() async {
    emit(AdminDeliveriesLoading());
    try {
      final response = await supabaseClient
          .from('delivery')
          .select('*')
          .order('created_at', ascending: false);

      _allDeliveries = List<Map<String, dynamic>>.from(response);

      if (_allDeliveries.isEmpty) {
        emit(DeliveriesListEmpty());
      } else {
        emit(AdminDeliveriesLoaded(deliveries: _allDeliveries));
      }
    } catch (e) {
      emit(AdminDeliveriesError(message: e.toString()));
    }
  }

  Future<void> toggleDeliveryStatus(
      String deliveryId, bool currentStatus) async {
    try {
      final updatedStatus = !currentStatus;

      await supabaseClient
          .from('delivery')
          .update({'is_active': updatedStatus}).eq('id', deliveryId);

      // Update local state
      final updatedIndex =
          _allDeliveries.indexWhere((d) => d['id'] == deliveryId);
      if (updatedIndex != -1) {
        _allDeliveries[updatedIndex]['is_active'] = updatedStatus;
        emit(DeliveryStatusUpdated(
            updatedDelivery: _allDeliveries[updatedIndex]));
        emit(AdminDeliveriesLoaded(deliveries: _allDeliveries));
      }
    } catch (e) {
      emit(AdminDeliveriesError(
          message: 'Failed to update status: ${e.toString()}'));
    }
  }
}
