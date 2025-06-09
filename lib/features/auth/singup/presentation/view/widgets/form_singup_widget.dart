import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/util/validators.dart';
import 'package:drivo_app/core/widgets/custom_button_widget.dart';
import 'package:drivo_app/core/widgets/custom_text_form_field_widget.dart';
import 'package:drivo_app/features/auth/login/presentation/view/widgets/divider_login_widget.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';

class FormSignupWidget extends StatefulWidget {
  const FormSignupWidget({super.key});

  @override
  State<FormSignupWidget> createState() => _FormSignupWidgetState();
}

class _FormSignupWidgetState extends State<FormSignupWidget> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _facilityNameController = TextEditingController();
  final TextEditingController _deliveryLicenseController =
      TextEditingController();
  bool _obscurePassword = true;
  final List<String> _directorates = [
    'التواهي',
    'المنصورة',
    'الشيخ',
    'كريتر',
    'البريقه',
    'المعلا',
    'بئر احمد',
    'المدينه الخضراء',
    'انماء',
    'انماء الجديدة',
    'دار سعد',
    'الخور',
    'القلوعة',
    'عدن الجديدة'
  ];

  final List<String> _userTypes = ['client', 'delivery', 'facility'];
  final List<String> _facilityCategories = [
    'restaurant',
    'grocery',
    'pharmacy',
    'other'
  ];

  String _selectedDirectorate = 'التواهي';
  String _selectedUserType = 'client';
  String _selectedFacilityCategory = 'restaurant';

  final GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                "انشاء حساب",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                value: _selectedUserType,
                items: _userTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getUserTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedUserType = value!),
                decoration: const InputDecoration(
                  labelText: 'نوع المستخدم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              CustomTextFormFieldWidget(
                controller: _userNameController,
                hintText: "اسم المستخدم",
                prefixIcon: const Icon(Icons.person),
                validator: (value) => Validators.validateName(value),
              ),
              const SizedBox(height: 20),
              CustomTextFormFieldWidget(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "الايميل",
                prefixIcon: const Icon(Icons.email),
                validator: (value) => Validators.validateEmail(value),
              ),
              const SizedBox(height: 20),
              CustomTextFormFieldWidget(
                controller: _phoneController,
                hintText: "رقم الهاتف",
                prefixIcon: const Icon(Icons.phone),
                validator: (value) => Validators.validatePhone(value),
              ),
              const SizedBox(height: 20),

              // Location fields
              DropdownButtonFormField<String>(
                value: _selectedDirectorate,
                items: _directorates.map((dir) {
                  return DropdownMenuItem(
                    value: dir,
                    child: Text(dir),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDirectorate = value!),
                decoration: const InputDecoration(
                  labelText: 'المديرية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Conditional fields based on user type
              if (_selectedUserType == 'facility') ...[
                CustomTextFormFieldWidget(
                  controller: _facilityNameController,
                  hintText: "اسم المنشأة",
                  prefixIcon: const Icon(Icons.business),
                  validator: (value) =>
                      value!.isEmpty ? 'يجب إدخال اسم المنشأة' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  focusColor: Theme.of(context).primaryColor,
                  value: _selectedFacilityCategory,
                  alignment: Alignment.topCenter,
                  borderRadius: BorderRadius.circular(16),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  items: _facilityCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(_getFacilityCategoryName(cat)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != 'restaurant') {
                      CustomSnackbar(
                        context: context,
                        snackBarType: SnackBarType.fail,
                        label: "حاليا يمكنك اختيار مطعم فقط",
                      );
                      setState(() => _selectedFacilityCategory = 'restaurant');
                      setState(() {});
                    } else {
                      setState(() => _selectedFacilityCategory = value!);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'نوع المنشأة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_selectedUserType == 'delivery') ...[
                CustomTextFormFieldWidget(
                  controller: _deliveryLicenseController,
                  hintText: "رقم الرخصة",
                  prefixIcon: const Icon(Icons.card_membership),
                  validator: (value) =>
                      value!.isEmpty ? 'يجب إدخال رقم الرخصة' : null,
                ),
                const SizedBox(height: 20),
              ],

              CustomTextFormFieldWidget(
                controller: _passwordController,
                hintText: "كلمة السر",
                obscureText: _obscurePassword ? true : false,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                prefixIcon: const Icon(Icons.lock),
                validator: (value) => Validators.validatePassword(value),
              ),
              const SizedBox(height: 30),

              // Signup button
              CustomButtonWidget(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<SignupCubit>().signup(
                          context: context,
                          email: _emailController.text,
                          password: _passwordController.text,
                          userName: _userNameController.text,
                          phoneNumber: _phoneController.text,
                          directorate: _selectedDirectorate,
                          userType: _selectedUserType,
                          facilityName: _selectedUserType == 'facility'
                              ? _facilityNameController.text
                              : null,
                          facilityCategory: _selectedUserType == 'facility'
                              ? _selectedFacilityCategory
                              : null,
                          deliveryLicense: _selectedUserType == 'delivery'
                              ? _deliveryLicenseController.text
                              : null,
                        );
                  } else {
                    setState(() {
                      _autovalidateMode = AutovalidateMode.always;
                    });
                  }
                },
                text: "انشاء حساب",
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
                child: DividerLoginWidget(),
              ),
              CustomButtonWidget(
                onTap: () {
                  CustomSnackbar(
                      context: context,
                      snackBarType: SnackBarType.fail,
                      label: "لم يتم التطوير بعد");
                },
                widget: SvgPicture.asset("assets/images/google.svg"),
                color: Theme.of(context).canvasColor,
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getUserTypeName(String type) {
    switch (type) {
      case 'client':
        return 'عميل';
      case 'delivery':
        return 'موصل';
      case 'facility':
        return 'منشأة';
      default:
        return type;
    }
  }

  String _getFacilityCategoryName(String category) {
    switch (category) {
      case 'restaurant':
        return 'مطعم';
      case 'grocery':
        return 'بقالة';
      case 'pharmacy':
        return 'صيدلية';
      case 'other':
        return 'أخرى';
      default:
        return category;
    }
  }
}
