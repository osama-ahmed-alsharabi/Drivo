import 'package:drivo_app/core/helpers/image_picker_helper.dart';
import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/add_product/add_product_cubit.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddProductPage extends StatefulWidget {
  final ProductModel? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'برجر';
  bool _isAvailable = true;

  final List<String> _categories = [
    'الشبس والصوصات',
    'بروست',
    'ايسكريم',
    'الأرز',
    'الشوربة',
    'المقبلات',
    'شاورما',
    'مشكل فرن',
    'اللحوم',
    'فاهيتا وزنجر',
    'القلابة',
    'مأكولات هندية',
    'مأكولات بحرية',
    'برجر',
    'مشاوي',
    'سلطات',
    'الفتة',
    'باستا ومكرونة',
    'بيتزا',
    'مشروبات',
    'مشروبات ساخنة',
    'أطباق حلى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product?.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _selectedCategory = widget.product!.category ?? 'برجر';
      _isAvailable = widget.product!.isAvailable;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePickerHelper.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BlocConsumer<AddProductCubit, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ المنتج بنجاح')),
            );
            BlocProvider.of<FetchProductsServiceProviderCubit>(context)
                .hasLoaded = true;
            BlocProvider.of<FetchProductsServiceProviderCubit>(context)
                .fetchProducts();
            BlocProvider.of<FetchProductsServiceProviderCubit>(context)
                .hasLoaded = false;
            Navigator.pop(context);
          } else if (state is AddProductFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state is AddProductLoading,
            opacity: 1,
            color: Theme.of(context).primaryColor,
            progressIndicator: Center(
              child: Image.asset('assets/images/logo_waiting.gif'),
            ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(widget.product == null
                    ? 'إضافة منتج جديد'
                    : 'تعديل المنتج'),
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
                            child: _imagePath == null &&
                                    widget.product?.imageUrl == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text('إضافة صورة المنتج'),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: _imagePath != null
                                        ? Image.file(
                                            File(_imagePath!),
                                            fit: BoxFit.cover,
                                          )
                                        : widget.product?.imageUrl != null
                                            ? Image.network(
                                                widget.product!.imageUrl!,
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم المنتج',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المنتج';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'وصف المنتج (اختياري)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'السعر',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال سعر المنتج';
                            }
                            if (double.tryParse(value) == null) {
                              return 'الرجاء إدخال سعر صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('متوفر'),
                          value: _isAvailable,
                          onChanged: (bool value) {
                            setState(() {
                              _isAvailable = value;
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
                            String? userId =
                                await SharedPreferencesService.getUserId();
                            if (_formKey.currentState!.validate()) {
                              final product = ProductModel(
                                id: widget.product?.id,
                                name: _nameController.text,
                                description: _descriptionController.text.isEmpty
                                    ? null
                                    : _descriptionController.text,
                                price: double.parse(_priceController.text),
                                category: _selectedCategory,
                                isAvailable: _isAvailable,
                                restaurantId: userId!,
                              );

                              if (widget.product == null) {
                                if (_imagePath != null) {
                                  if (!context.mounted) return;
                                  await context
                                      .read<AddProductCubit>()
                                      .addProduct(
                                        product: product,
                                        imagePath: _imagePath!,
                                      );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('الرجاء إضافة صورة للمنتج')),
                                  );
                                }
                              } else {
                                if (!context.mounted) return;
                                await context
                                    .read<AddProductCubit>()
                                    .updateProduct(
                                      product: product,
                                      imagePath: _imagePath,
                                    );
                              }
                            }
                          },
                          child: Text(
                            widget.product == null
                                ? 'حفظ المنتج'
                                : 'تحديث المنتج',
                            style: const TextStyle(
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
