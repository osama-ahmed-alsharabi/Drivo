// lib/features/admin/report/presentation/view_model/cubit/reports_state.dart
import 'package:drivo_app/features/admin/admin_reports/presentation/view/admin_report_view.dart';
import 'package:equatable/equatable.dart';

abstract class AdminReportState extends Equatable {
  const AdminReportState();

  @override
  List<Object> get props => [];
}

class AdminReportInitial extends AdminReportState {}

class AdminReportLoading extends AdminReportState {}

class AdminReportLoaded extends AdminReportState {
  final AdminReport report;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdminReportLoaded(this.report, {this.startDate, this.endDate});

  @override
  List<Object> get props => [report, startDate ?? '', endDate ?? ''];
}

class AdminReportError extends AdminReportState {
  final String message;

  const AdminReportError(this.message);

  @override
  List<Object> get props => [message];
}
