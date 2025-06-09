// features/admin/deliveries/presentation/view_model/cubit/admin_deliveries_state.dart

import 'package:equatable/equatable.dart';

abstract class AdminDeliveriesState extends Equatable {
  const AdminDeliveriesState();

  @override
  List<Object> get props => [];
}

class AdminDeliveriesInitial extends AdminDeliveriesState {}

class AdminDeliveriesLoading extends AdminDeliveriesState {}

class AdminDeliveriesLoaded extends AdminDeliveriesState {
  final List<Map<String, dynamic>> deliveries;
  const AdminDeliveriesLoaded({required this.deliveries});

  @override
  List<Object> get props => [deliveries];
}

class AdminDeliveriesError extends AdminDeliveriesState {
  final String message;
  const AdminDeliveriesError({required this.message});

  @override
  List<Object> get props => [message];
}

class DeliveriesListEmpty extends AdminDeliveriesState {}

class DeliveryStatusUpdated extends AdminDeliveriesState {
  final Map<String, dynamic> updatedDelivery;
  const DeliveryStatusUpdated({required this.updatedDelivery});

  @override
  List<Object> get props => [updatedDelivery];
}
