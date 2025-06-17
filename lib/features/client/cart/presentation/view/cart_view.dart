import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/price_converter.dart';
import 'package:drivo_app/features/auth/login/presentation/view/login_view.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_state.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/client/address/presentation/view/widgets/addresses_bottom_sheet.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_cubit.dart';
import 'package:drivo_app/features/client/cart/presentation/view/order_detail_widget.dart';
import 'package:drivo_app/features/client/cart/presentation/view_model/order_cubit/order_cubit.dart';
import 'package:drivo_app/core/util/app_images.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderFree) {
            CustomSnackbar(
                context: context,
                label: "التوصيل مجانا",
                snackBarType: SnackBarType.success);
          }
          if (state is OrderSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  // ADD THIS WRAPPER
                  value: BlocProvider.of<CartCubit>(context),
                  child: OrderDetailsPage(
                    order: state.orderData,
                    exchangeRate: state.exchangeRate,
                    isFree: state is OrderFree,
                  ),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is OrderSubmitting,
              opacity: 1,
              color: Theme.of(context).primaryColor,
              progressIndicator: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.logoWaitingGif),
                  const SizedBox(height: 20),
                  const Text(
                    'جاري معالجة الطلب...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              child: Scaffold(
                appBar: CartAppBar(
                  onClearCartPressed: () => _showClearCartDialog(context),
                ),
                body: BlocBuilder<CartCubit, CartState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    if (state is CartInitial ||
                        (state is CartUpdated && state.cartItems.isEmpty)) {
                      return const EmptyCartWidget();
                    } else if (state is CartUpdated) {
                      return _buildCartItemsList(state.cartItems, context);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    if (state is CartUpdated && state.cartItems.isNotEmpty) {
                      return CheckoutBarWidget(
                        onCheckoutPressed: () =>
                            _showPaymentMethodsBottomSheet(context),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCartItemsList(List<CartItem> cartItems, BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemWidget(
                item: item,
                onRemove: () {
                  context.read<CartCubit>().removeFromCart(item.product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف ${item.product.name} من السلة'),
                      action: SnackBarAction(
                        label: 'تراجع',
                        onPressed: () {
                          context.read<CartCubit>().addToCart(
                                item.product,
                                quantity: item.quantity,
                              );
                        },
                      ),
                    ),
                  );
                },
                onIncreaseQuantity: () {
                  context.read<CartCubit>().updateQuantity(
                        item.product.id!,
                        item.quantity + 1,
                      );
                },
                onDecreaseQuantity: () {
                  if (item.quantity > 1) {
                    context.read<CartCubit>().updateQuantity(
                          item.product.id!,
                          item.quantity - 1,
                        );
                  } else {
                    _showClearCartDialogforDecrement(context, item);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClearCartDialogforDecrement(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف المنتج"),
        content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
                'هل أنت متأكد أنك تريد حذف ${item.product.name} من السلة؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().removeFromCart(item.product.id!);
              Navigator.pop(context);
            },
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفريغ السلة'),
        content: const Text('هل أنت متأكد أنك تريد حذف جميع العناصر من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(context);
            },
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsBottomSheet(BuildContext context) async {
    final addressState = context.read<AddressCubit>().state;
    if (addressState is! AddressLoaded || addressState.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تحديد عنوان التوصيل أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final defaultAddress = addressState.addresses.firstWhere(
      (address) => address['isDefault'] == 1,
      orElse: () => {},
    );

    if (defaultAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تحديد عنوان افتراضي للتوصيل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return PaymentMethodsSheet(
          onCashPaymentSelected: () => _processOrder(context, defaultAddress),
        );
      },
    );
  }

  Future<void> _processOrder(
      BuildContext context, Map<String, dynamic> address) async {
    final cartState = context.read<CartCubit>().state;
    if (cartState is! CartUpdated || cartState.cartItems.isEmpty) return;

    final userId = await SharedPreferencesService.getUserId();
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول أولاً'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;
    context.read<OrderCubit>().submitOrder(
          cartItems: cartState.cartItems,
          address: address,
          userId: userId,
        );
  }
}

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearCartPressed;

  const CartAppBar({
    super.key,
    required this.onClearCartPressed,
  });
  static String? user;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) async {
          user = await SharedPreferencesService.getUserId();
        },
        builder: (context, state) {
          if (state is AddressLoaded) {
            final defaultAddress = state.addresses.firstWhere(
              (address) => address['isDefault'] == 1,
              orElse: () => {},
            );
            if (defaultAddress.isNotEmpty) {
              return GestureDetector(
                onTap: () => _showAddressSelection(context),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      defaultAddress['title'] ?? 'عنوان التوصيل',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              );
            }
          }
          return user != null
              ? GestureDetector(
                  onTap: () => _showAddressSelection(context),
                  child: const Text(
                    'إضافة عنوان التوصيل',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                  child: const Text(
                    'قم بتسجيل الدخول',
                    style: TextStyle(fontSize: 16),
                  ),
                );
        },
      ),
      centerTitle: false,
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartUpdated && state.cartItems.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onClearCartPressed,
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _showAddressSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const AddressesBottomSheet(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PaymentMethodsSheet extends StatefulWidget {
  final VoidCallback onCashPaymentSelected;

  const PaymentMethodsSheet({
    super.key,
    required this.onCashPaymentSelected,
  });

  @override
  State<PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<PaymentMethodsSheet> {
  int? selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "اختر طريقة الدفع",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodItem(
              context,
              title: "عند الاستلام",
              isSelected: selectedPaymentMethod == 0,
              onTap: () => setState(() => selectedPaymentMethod = 0),
            ),
            _buildPaymentMethodItem(
              context,
              title: "القطيبي",
              isSelected: selectedPaymentMethod == 1,
              onTap: () => setState(() => selectedPaymentMethod = 1),
            ),
            _buildPaymentMethodItem(
              context,
              title: "الكريمي",
              isSelected: selectedPaymentMethod == 2,
              onTap: () => setState(() => selectedPaymentMethod = 2),
            ),
            _buildPaymentMethodItem(
              context,
              title: "بنك عدن",
              isSelected: selectedPaymentMethod == 3,
              onTap: () => setState(() => selectedPaymentMethod = 3),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (selectedPaymentMethod == 0) {
                    widget.onCashPaymentSelected();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("لم يتم التطوير بعد"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "تأكيد",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutBarWidget extends StatelessWidget {
  final VoidCallback onCheckoutPressed;

  const CheckoutBarWidget({
    super.key,
    required this.onCheckoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartUpdated) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "${context.read<CartCubit>().totalPrice.toStringAsFixed(2)} ر.ي",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onCheckoutPressed,
              child: const Text(
                'إتمام الشراء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onRemove(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.product.imageUrl == null
                    ? Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.shopping_bag),
                      )
                    : Image.network(
                        item.product.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${PriceConverter.formatNumberWithCommas(PriceConverter.convertToYemeni(
                        saudiPrice: item.product.price,
                        exchangeRate: item.product.exchangeRate ?? 1,
                      ))} ر.ي',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncreaseQuantity,
                  ),
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: onDecreaseQuantity,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          AppImages.emptyCartLottie,
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
        const Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'سلة التسوق فارغة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'تصفح المنتجات وأضف ما يعجبك إلى السلة',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
