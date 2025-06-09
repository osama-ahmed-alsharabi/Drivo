import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/helpers/image_picker_helper.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/add_offer/data/model/offer_model.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/adding_offer_service_provider_cubit/adding_offer_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'; // Add this import

class AddOfferServiceProviderPage extends StatefulWidget {
  const AddOfferServiceProviderPage({super.key});

  @override
  State<AddOfferServiceProviderPage> createState() =>
      _AddOfferServiceProviderPageState();
}

class _AddOfferServiceProviderPageState
    extends State<AddOfferServiceProviderPage> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  late DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final bool _isActive = true;

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
    return Builder(builder: (context) {
      return BlocConsumer<AddOfferCubit, AddingOfferServiceProviderState>(
        listener: (context, state) {
          if (state is AddingOfferServiceProviderSuccess) {
            CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.success,
                label: state.message);
            BlocProvider.of<FetchOfferServiceProviderCubit>(context).hasLoaded =
                true;
            BlocProvider.of<FetchOfferServiceProviderCubit>(context)
                .fetchOfferServiceProvider();
            BlocProvider.of<FetchOfferServiceProviderCubit>(context).hasLoaded =
                false;
            Navigator.pop(context);
          } else if (state is AddingOfferServiceProviderFailure) {
            CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.fail,
                label: "تأكد من الاتصال بالانترنت");
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AddingOfferServiceProviderLoading,
            opacity: 1,
            color: Theme.of(context).primaryColor,
            progressIndicator: Center(
              child: Image.asset('assets/images/logo_waiting.gif'),
            ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text('إضافة عرض جديد'),
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
                            child: _imagePath == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text('إضافة صورة العرض'),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          title: const Text('تاريخ الانتهاء'),
                          subtitle: Text('${_endDate.toLocal()}'.split(' ')[0]),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context),
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
                            String? userId =
                                await SharedPreferencesService.getUserId();
                            if (_formKey.currentState!.validate() &&
                                _imagePath != null) {
                              final offer = OfferModel(
                                id: null,
                                restaurantId: userId!,
                                imageUrl: '',
                                isActive: false,
                                createdAt: DateTime.now(),
                                endDate: _endDate,
                              );

                              await context.read<AddOfferCubit>().addOffer(
                                    offer: offer,
                                    imagePath: _imagePath!,
                                  );
                              BlocProvider.of<FetchOfferServiceProviderCubit>(
                                      context)
                                  .fetchOfferServiceProvider();
                            }
                          },
                          child: const Text(
                            'حفظ العرض',
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
    });
  }
}
