part of 'favorite_cubit.dart';

@immutable
abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<ProductModel> favorites;
  final double exchange;

  FavoriteLoaded(this.favorites, this.exchange);
}

class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError(this.message);
}
