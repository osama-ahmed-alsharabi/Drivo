import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/image_picker_helper.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/edit_offer/edit_offer_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'; // Add this import

class EditOfferPage extends StatefulWidget {
  final OfferModel offer;
  const EditOfferPage({super.key, required this.offer});

  @override
  State<EditOfferPage> createState() => _EditOfferPageState();
}

class _EditOfferPageState extends State<EditOfferPage> {
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

  Future<void> _pickImage() async {
    final XFile? image = await ImagePickerHelper.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditOfferCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<EditOfferCubit, EditOfferState>(
          listener: (context, state) async {
            if (state is EditOfferSuccess) {
              CustomSnackbar(
                  context: context,
                  snackBarType: SnackBarType.success,
                  label: state.message);
              BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                  .hasLoaded = true;
              await BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                  .fetchOfferServiceProvider();
              Navigator.pop(context, true);
            } else if (state is EditOfferFailure) {
              CustomSnackbar(
                  context: context,
                  snackBarType: SnackBarType.fail,
                  label: "تأكد من الاتصال بالانترنت");
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is EditOfferLoading,
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
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
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
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            title: const Text('تاريخ الانتهاء'),
                            subtitle:
                                Text('${_endDate.toLocal()}'.split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 10),
                          // SwitchListTile(
                          //   title: const Text('العرض نشط'),
                          //   value: _isActive,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _isActive = value;
                          //     });
                          //   },
                          // ),
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
                                  isActive: false,
                                );

                                // await context.read<EditOfferCubit>().editOffer(
                                //       offer: updatedOffer,
                                //       imagePath: _imagePath,
                                //     );

                                await BlocProvider.of<EditOfferCubit>(context)
                                    .editOffer(
                                        offer: updatedOffer,
                                        imagePath: _imagePath);
                                BlocProvider.of<FetchOfferServiceProviderCubit>(
                                    context);
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
