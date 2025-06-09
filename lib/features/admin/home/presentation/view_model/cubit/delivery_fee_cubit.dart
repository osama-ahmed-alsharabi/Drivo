// features/admin/delivery_fee/presentation/view_model/cubit/delivery_fee_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'delivery_fee_state.dart';

class DeliveryFeeCubit extends Cubit<DeliveryFeeState> {
  final SupabaseClient _supabase;

  DeliveryFeeCubit(this._supabase) : super(DeliveryFeeInitial());

  Future<void> loadDeliveryFee() async {
    emit(DeliveryFeeLoading());
    try {
      final response = await _supabase
          .from('delivery_fee')
          .select('*')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        emit(const DeliveryFeeLoaded(feePerKm: 0.0));
      } else {
        final fee = response[0]['fee_per_km'] as double;
        emit(DeliveryFeeLoaded(feePerKm: fee));
      }
    } catch (e) {
      emit(DeliveryFeeError(message: e.toString()));
    }
  }

  Future<void> updateDeliveryFee(double newFee) async {
    emit(DeliveryFeeLoading());
    try {
      await _supabase.from('delivery_fee').insert({
        'fee_per_km': newFee,
        'created_at': DateTime.now().toIso8601String(),
      });

      emit(DeliveryFeeLoaded(feePerKm: newFee));
    } catch (e) {
      emit(DeliveryFeeError(message: e.toString()));
    }
  }
}
