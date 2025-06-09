import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/widgets/custom_button_widget.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_cubit.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';

class OtpVerificationView extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationView({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupFailure) {
            CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.fail,
                label: "حدث خطاء الرجاء المحاولة لاحقا");
          } else if (state is SignupOtpResent) {
            CustomSnackbar(
                context: context,
                snackBarType: SnackBarType.success,
                label: 'تم إعادة إرسال رمز التحقق');
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.08,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )),
                        ),
                        Positioned(
                          bottom: -30,
                          left: (MediaQuery.of(context).size.width / 2) - 35,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/images/small_logo.svg",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "تحقق من الرمز",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "لقد أرسلنا رمز التحقق إلى ${widget.phoneNumber}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 40),
                          // OTP Input Fields
                          _buildOtpInput(context),
                          const SizedBox(height: 20),
                          if (state is SignupLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            CustomButtonWidget(
                              onTap: () {
                                final otpCode = _otpControllers
                                    .map((controller) => controller.text)
                                    .join();
                                if (otpCode.length == 6) {
                                  context
                                      .read<SignupCubit>()
                                      .verifyOtp(otpCode, context);
                                } else {
                                  CustomSnackbar(
                                      context: context,
                                      snackBarType: SnackBarType.alert,
                                      label: 'الرجاء إدخال رمز التحقق كاملاً');
                                }
                              },
                              text: "تحقق",
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "لم تستلم الرمز؟",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<SignupCubit>()
                                      .resendOtp(context);
                                },
                                child: const Text("إعادة إرسال"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return SizedBox(
            width: 45,
            child: TextFormField(
              controller: _otpControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
