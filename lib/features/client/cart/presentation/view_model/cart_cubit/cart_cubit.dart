// cart_cubit.dart
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:equatable/equatable.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  List<CartItem> _cartItems = [];

  double get totalPrice {
    return _cartItems.fold(
        0.0,
        (sum, item) =>
            sum +
            (PriceConverter.convertToYemeni(
                    saudiPrice: item.product.price,
                    exchangeRate: item.product.exchangeRate ?? 1) *
                item.quantity));
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex]
          .copyWith(quantity: _cartItems[existingIndex].quantity + quantity);
    } else {
      _cartItems = [
        ..._cartItems,
        CartItem(product: product, quantity: quantity)
      ];
    }

    emit(CartUpdated(cartItems: List.from(_cartItems)));
  }

  void removeFromCart(String productId) {
    _cartItems =
        _cartItems.where((item) => item.product.id != productId).toList();
    emit(CartUpdated(cartItems: List.from(_cartItems)));
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      emit(CartUpdated(cartItems: List.from(_cartItems)));
    }
  }

  void clearCart() {
    _cartItems = [];
    emit(const CartUpdated(cartItems: []));
  }
}

class CartItem extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity];
}
