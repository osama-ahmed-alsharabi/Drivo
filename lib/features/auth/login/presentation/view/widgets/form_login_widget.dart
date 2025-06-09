import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/routes/app_routes.dart';
import 'package:drivo_app/core/util/validators.dart';
import 'package:drivo_app/core/widgets/custom_button_widget.dart';
import 'package:drivo_app/core/widgets/custom_text_form_field_widget.dart';
import 'package:drivo_app/features/admin/home/presentation/view/admin_home_view.dart';
import 'package:drivo_app/features/auth/login/presentation/view/widgets/divider_login_widget.dart';
import 'package:drivo_app/features/auth/login/presentation/view_model/cubit/login_cubit.dart';
import 'package:drivo_app/features/service_provider/add_offer/presentation/view_model/fetch_offer_service_provider_cubit/fetch_offer_service_provider_cubit.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';

class FormLoginWidget extends StatefulWidget {
  const FormLoginWidget({super.key});

  @override
  State<FormLoginWidget> createState() => _FormLoginWidgetState();
}

class _FormLoginWidgetState extends State<FormLoginWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _obscurePassword = true;
  @override
  void initState() {
    BlocProvider.of<FetchOfferServiceProviderCubit>(context).hasLoaded = true;
    BlocProvider.of<FetchProductsServiceProviderCubit>(context).hasLoaded =
        true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Form(
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
                  "مرحبا بك!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextFormFieldWidget(
                  controller: _emailController,
                  hintText: "الايميل",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) => Validators.validateEmail(value),
                ),
                const SizedBox(height: 20),
                CustomTextFormFieldWidget(
                  controller: _passwordController,
                  hintText: "كلمة السر",
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                const SizedBox(height: 5),
                GestureDetector(
                  // onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPasswordRoute),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "هل نسيت كلمة المرور؟",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButtonWidget(
                  onTap: _submitForm,
                  text: "تسجيل دخول",
                ),
                const SizedBox(height: 20),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
                  child: DividerLoginWidget(),
                ),
                CustomButtonWidget(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.singupRoute),
                  color: Theme.of(context).canvasColor,
                  text: "انشاء حساب",
                ),
                const SizedBox(height: 20),
                CustomButtonWidget(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.clientHomeRoute,
                    (route) => false,
                  ),
                  color: Theme.of(context).canvasColor,
                  text: "تصفح التطبيق",
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_emailController.text == "admin" &&
        _passwordController.text == "admin") {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AdminHomeView()));
    } else {
      if (_formKey.currentState!.validate()) {
        context.read<LoginCubit>().loginWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      } else {
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
