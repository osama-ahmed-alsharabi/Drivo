// features/admin/exchange/presentation/view_model/cubit/exchange_state.dart
part of 'exchange_cubit.dart';

abstract class ExchangeState extends Equatable {
  const ExchangeState();

  @override
  List<Object> get props => [];
}

class ExchangeInitial extends ExchangeState {}

class ExchangeLoading extends ExchangeState {}

class ExchangeLoaded extends ExchangeState {
  final double rate;
  const ExchangeLoaded({required this.rate});

  @override
  List<Object> get props => [rate];
}

class ExchangeError extends ExchangeState {
  final String message;
  const ExchangeError({required this.message});

  @override
  List<Object> get props => [message];
}
