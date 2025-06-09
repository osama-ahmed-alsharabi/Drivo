part of 'fetch_client_products_cubit.dart';

sealed class FetchClientProductsState extends Equatable {
  const FetchClientProductsState();

  @override
  List<Object> get props => [];
}

final class FetchClientProductsInitial extends FetchClientProductsState {}

final class FetchClientProductsSuccess extends FetchClientProductsState {}

final class FetchClientProductsLoading extends FetchClientProductsState {}

final class FetchClientProductsFaulier extends FetchClientProductsState {}
