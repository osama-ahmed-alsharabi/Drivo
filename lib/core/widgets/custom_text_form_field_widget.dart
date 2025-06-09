import 'package:flutter/material.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  final String hintText;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  const CustomTextFormFieldWidget({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return "الرجاء ادخال الحقل";
            } else {
              return null;
            }
          },
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: borderMethod(context),
        focusedBorder: borderMethod(context),
        errorBorder: borderMethod(context, color: Colors.red),
        focusedErrorBorder: borderMethod(context, color: Colors.red),
      ),
    );
  }

  OutlineInputBorder borderMethod(BuildContext context, {Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
