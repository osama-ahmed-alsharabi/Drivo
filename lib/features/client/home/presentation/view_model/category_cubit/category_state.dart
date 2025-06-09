part of 'category_cubit.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

final class CategoryInitial extends CategoryState {}

final class CategorySuccess extends CategoryState {
  final List<CategoryModel>? categoryModel;

  const CategorySuccess({this.categoryModel});
}
