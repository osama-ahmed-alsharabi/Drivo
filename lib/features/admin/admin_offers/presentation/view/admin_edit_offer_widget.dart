import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view_model/admin_edit_offer_cubit/admin_edit_offer_cubit_cubit.dart';
import 'package:drivo_app/features/admin/admin_offers/presentation/view_model/admin_fetch_offer_cubit/admin_fetch_offers_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AdminEditOfferWidget extends StatefulWidget {
  final OfferModel offer;
  final bool? isAdmin;
  const AdminEditOfferWidget({super.key, required this.offer, this.isAdmin});

  @override
  State<AdminEditOfferWidget> createState() => _AdminEditOfferWidgetState();
}

class _AdminEditOfferWidgetState extends State<AdminEditOfferWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  late DateTime _endDate;
  late bool _isActive;
  @override
  void initState() {
    super.initState();
    _endDate = widget.offer.endDate;
    _isActive = widget.offer.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminEditOfferCubitCubit(),
        ),
        BlocProvider(create: (context) => AdminFetchOffersCubit()),
      ],
      child: Builder(builder: (context) {
        return BlocConsumer<AdminEditOfferCubitCubit, AdminEditOfferCubitState>(
          listener: (context, state) async {
            if (state is AdminEditOfferCubitSuccess) {
              // Force refresh the offers list
              BlocProvider.of<AdminFetchOffersCubit>(context).hasLoaded = true;
              await BlocProvider.of<AdminFetchOffersCubit>(context)
                  .adminFetchOffers();
              // if (mounted) {
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
              CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.success,
                label: "تم التعديل بنجاح",
              );
              // }
            } else if (state is AdminEditOfferCubitFauler) {
              CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.fail,
                label: "تأكد من الاتصال بالانترنت",
              );
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is AdminEditOfferCubitLoading,
              opacity: 1,
              color: Theme.of(context).primaryColor,
              progressIndicator: Center(
                child: Image.asset('assets/images/logo_waiting.gif'),
              ),
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  title: const Text('تعديل العرض'),
                  centerTitle: true,
                ),
                body: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : widget.offer.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          widget.offer.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo,
                                              size: 50, color: Colors.grey),
                                          SizedBox(height: 10),
                                          Text('تغيير صورة العرض'),
                                        ],
                                      ),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            title: const Text('تاريخ الانتهاء'),
                            subtitle:
                                Text('${_endDate.toLocal()}'.split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            title: const Text('تفعيل العرض'),
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final updatedOffer = widget.offer.copyWith(
                                  endDate: _endDate,
                                  isActive: _isActive,
                                );

                                await context
                                    .read<AdminEditOfferCubitCubit>()
                                    .adminEditOffers(
                                      updatedOffer: updatedOffer,
                                    );
                              }
                            },
                            child: const Text(
                              'حفظ التعديلات',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
