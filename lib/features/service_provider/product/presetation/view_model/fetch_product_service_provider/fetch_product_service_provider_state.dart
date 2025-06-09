import 'package:equatable/equatable.dart';

abstract class FetchProductsState extends Equatable {
  const FetchProductsState();

  @override
  List<Object> get props => [];
}

class FetchProductsInitial extends FetchProductsState {}

class FetchProductsLoading extends FetchProductsState {}

class FetchProductsSuccess extends FetchProductsState {}

class FetchProductsFailure extends FetchProductsState {
  final String errorMessage;
  const FetchProductsFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class FetchProductsDeleteSuccess extends FetchProductsState {}

class FetchProductsDeleteFailure extends FetchProductsState {
  final String errorMessage;
  const FetchProductsDeleteFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
