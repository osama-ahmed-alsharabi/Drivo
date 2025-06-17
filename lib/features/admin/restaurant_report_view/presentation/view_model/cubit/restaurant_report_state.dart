// lib/features/restaurant/report/presentation/cubit/restaurant_report_state.dart
import 'package:drivo_app/features/admin/restaurant_report_view/presentation/restaurant_report_view.dart';
import 'package:equatable/equatable.dart';

abstract class RestaurantReportState extends Equatable {
  const RestaurantReportState();

  @override
  List<Object> get props => [];
}

class RestaurantReportInitial extends RestaurantReportState {}

class RestaurantReportLoading extends RestaurantReportState {}

class RestaurantReportLoaded extends RestaurantReportState {
  final RestaurantReport report;
  final DateTime? startDate;
  final DateTime? endDate;

  const RestaurantReportLoaded(this.report, {this.startDate, this.endDate});

  @override
  List<Object> get props => [report, startDate ?? '', endDate ?? ''];
}

class RestaurantReportError extends RestaurantReportState {
  final String message;

  const RestaurantReportError(this.message);

  @override
  List<Object> get props => [message];
}
