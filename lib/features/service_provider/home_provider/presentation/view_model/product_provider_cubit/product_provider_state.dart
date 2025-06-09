import 'package:drivo_app/features/service_provider/home_provider/data/model/product_model.dart';

abstract class ProductsProviderState {}

class ProductsProviderInitial extends ProductsProviderState {}

class ProductsProviderLoading extends ProductsProviderState {}

class ProductsProviderLoaded extends ProductsProviderState {
  final List<ProductModel> products;

  ProductsProviderLoaded(this.products);
}

class ProductsProviderError extends ProductsProviderState {
  final String message;

  ProductsProviderError(this.message);
}
