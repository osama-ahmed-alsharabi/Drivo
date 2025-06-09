// lib/features/client/orders/presentation/cubit/orders_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:drivo_app/features/client/profile/data/user_order_repo.dart';
import 'package:drivo_app/features/client/profile/presentation/view_model/cubit/user_order_state.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserOrdersCubit extends Cubit<UserOrdersState> {
  final UserOrdersRepository _repository;

  UserOrdersCubit(this._repository) : super(UserOrdersInitial());

  Future<void> fetchOrders(String userId) async {
    emit(UserOrdersLoading());
    try {
      final orders = await _repository.getUserOrders(userId);
      emit(UserOrdersLoaded(orders));
    } on PostgrestException catch (e) {
      emit(UserOrdersError(e.message));
    } catch (e) {
      emit(const UserOrdersError('Failed to fetch orders'));
    }
  }
}
