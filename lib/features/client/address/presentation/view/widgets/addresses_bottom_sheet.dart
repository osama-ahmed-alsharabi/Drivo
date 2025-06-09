import 'package:drivo_app/core/util/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drivo_app/features/client/address/presentation/view/add_address_map_screen.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_cubit.dart';
import 'package:drivo_app/features/client/address/presentation/view_model/cubit/address_state.dart';
import 'package:lottie/lottie.dart';

class AddressesBottomSheet extends StatelessWidget {
  const AddressesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'عناوين التوصيل',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AddressLoaded) {
          return state.addresses.isEmpty
              ? _buildEmptyState(context)
              : _buildAddressesList(context, state.addresses);
        }

        return const Center(
          child: Text(
            'حدث خطأ في تحميل العناوين',
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          AppImages.noLocationLottie,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        const Text(
          'لا يوجد عناوين مسجلة',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildAddressesList(
      BuildContext context, List<Map<String, dynamic>> addresses) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: addresses.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) =>
                _buildAddressCard(context, addresses[index]),
          ),
        ),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> address) {
    final isDefault = address['isDefault'] == 1;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDefault
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isDefault ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!isDefault) {
              context.read<AddressCubit>().setDefaultAddress(address['id']);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getAddressIcon(address['title']),
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  address['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(width: 8),
                                  _buildDefaultBadge(),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address['address'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (address['additionalInfo']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ملاحظات: ${address['additionalInfo']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isDefault)
                      TextButton(
                        onPressed: () => context
                            .read<AddressCubit>()
                            .setDefaultAddress(address['id']),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: Text(
                          'تعيين كافتراضي',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey.shade600),
                      onPressed: () => _showEditAddress(context, address),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade400),
                      onPressed: () =>
                          _showDeleteDialog(context, address['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'افتراضي',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 20),
        label: const Text('إضافة عنوان جديد'),
        onPressed: () => _showAddAddress(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String title) {
    if (title.contains('المنزل')) return Icons.home;
    if (title.contains('العمل')) return Icons.work;
    if (title.contains('أخرى')) return Icons.location_city;
    return Icons.location_on;
  }

  void _showAddAddress(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const AddAddressMapScreen(),
        ),
      ),
    ).then((_) => context.read<AddressCubit>().loadAddresses());
  }

  void _showEditAddress(BuildContext context, Map<String, dynamic> address) {
    final cubit = context.read<AddressCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: AddAddressMapScreen(initialAddress: address),
        ),
      ),
    ).then((_) => context.read<AddressCubit>().loadAddresses());
  }

  void _showDeleteDialog(BuildContext context, int addressId) {
    final cubit = context.read<AddressCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteAddress(addressId);
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
