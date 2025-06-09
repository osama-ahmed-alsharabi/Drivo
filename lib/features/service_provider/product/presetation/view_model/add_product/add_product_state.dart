part of 'add_product_cubit.dart';

abstract class AddProductState extends Equatable {
  const AddProductState();

  @override
  List<Object> get props => [];
}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {}

class AddProductFailure extends AddProductState {
  final String errorMessage;
  const AddProductFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
