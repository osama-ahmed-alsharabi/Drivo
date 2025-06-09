import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view/admin_edit_offer_widget.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view/widgets/edit_offer_page.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final bool? isAdmin;

  const OfferCard({super.key, required this.offer, this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: CachedNetworkImage(
                imageUrl: offer.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 4),
                      decoration: BoxDecoration(
                        color: offer.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        offer.isActive ? 'نشط' : 'غير نشط',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${offer.endDate.year}/${offer.endDate.month}/${offer.endDate.day}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        if (isAdmin ?? false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminEditOfferWidget(
                                offer: offer,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOfferPage(
                                offer: offer,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    BlocConsumer<FetchOfferServiceProviderCubit,
                        FetchOfferServiceProviderState>(
                      listener: (context, state) {
                        if (state is FetchOfferServiceProviderDeletedFauild) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.errorMessage)),
                          );
                        }
                      },
                      builder: (context, state) {
                        return IconButton(
                          icon: state is FetchOfferServiceProviderLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('حذف العرض'),
                                content: const Text(
                                    'هل أنت متأكد أنك تريد حذف هذا العرض؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await context
                                          .read<
                                              FetchOfferServiceProviderCubit>()
                                          .deleteOffer(offer);
                                    },
                                    child: const Text('حذف',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
