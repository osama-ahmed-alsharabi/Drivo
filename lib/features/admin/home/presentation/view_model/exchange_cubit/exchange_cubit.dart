// features/admin/exchange/presentation/view_model/cubit/exchange_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'exchange_state.dart';

class ExchangeCubit extends Cubit<ExchangeState> {
  final SupabaseClient _supabase;

  ExchangeCubit(this._supabase) : super(ExchangeInitial());

  Future<void> loadExchangeRate() async {
    emit(ExchangeLoading());
    try {
      final response = await _supabase
          .from('exchange_rate')
          .select('*')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        emit(const ExchangeLoaded(rate: 0.0));
      } else {
        final rate = response[0]['rate'] as double;
        emit(ExchangeLoaded(rate: rate));
      }
    } catch (e) {
      emit(ExchangeError(message: e.toString()));
    }
  }

  Future<void> updateExchangeRate(double newRate) async {
    emit(ExchangeLoading());
    try {
      await _supabase.from('exchange_rate').insert({
        'rate': newRate,
        'created_at': DateTime.now().toIso8601String(),
      });

      emit(ExchangeLoaded(rate: newRate));
    } catch (e) {
      emit(ExchangeError(message: e.toString()));
    }
  }
}
