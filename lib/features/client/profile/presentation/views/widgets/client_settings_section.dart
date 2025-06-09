import 'package:drivo_app/core/service/local_database_service.dart';
import 'package:drivo_app/features/client/address/presentation/view/widgets/addresses_bottom_sheet.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/client_list_tile_widget.dart';

class ClientSettingsSection extends StatelessWidget {
  const ClientSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(
        databaseService: context.read<DatabaseService>(),
      ),
      child: Builder(builder: (context) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClientListTile(
                icon: IconlyBold.location,
                title: "عناوين التوصيل",
                onTap: () => _showAddressesBottomSheet(context),
              ),
              const Divider(height: 1),
              ClientListTile(
                icon: IconlyBold.wallet,
                title: "طرق الدفع",
                onTap: () => _showPaymentMethodsBottomSheet(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showAddressesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.5, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: BlocProvider(
                  create: (context) => AddressCubit(
                    databaseService: context.read<DatabaseService>(),
                  )..loadAddresses(),
                  child: const AddressesBottomSheet(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPaymentMethodsBottomSheet(BuildContext context) {
    int? selectedPaymentMethod = 0; // 0 = عند الاستلام

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    // Draggable handle
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "اختر طريقة الدفع",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment methods list
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

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (selectedPaymentMethod == 0) {
                            CustomSnackbar(
                              context: context,
                              snackBarType: SnackBarType.success,
                              label: "تم اختيار الدفع عند الاستلام بنجاح",
                            );
                          } else {
                            CustomSnackbar(
                              context: context,
                              snackBarType: SnackBarType.fail,
                              label: "لم يتم التطوير بعد",
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
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
