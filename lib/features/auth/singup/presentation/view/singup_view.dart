import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/routes/app_routes.dart';
import 'package:drivo_app/features/auth/singup/presentation/view/widgets/form_singup_widget.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_cubit.dart';
import 'package:drivo_app/features/auth/singup/presentation/view_model/signUp_cubit/singup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(builder: (context) {
        return BlocConsumer<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupFailure) {
            } else if (state is SignupSuccess) {
              Navigator.pushNamed(
                context,
                AppRoutes.otpVerificationRoute,
                arguments: state.phoneNumber,
              );
            } else if (state is SignupVerificationSuccess) {
              if (state.userType == "client") {
                CustomSnackbar(
                    context: context,
                    snackBarType: SnackBarType.success,
                    label: "قم بتسجيل الدخول");
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                CustomSnackbar(
                    context: context,
                    snackBarType: SnackBarType.success,
                    label: "سوف يتم مراجعت الحساب من قبل المشرف");
                Navigator.pop(context);
                Navigator.pop(context);
              }
            }
          },
          builder: (context, state) {
            return ModalProgressHUD(
              inAsyncCall: state is SignupLoading,
              opacity: 1,
              color: Theme.of(context).primaryColor,
              progressIndicator: Center(
                child: Image.asset('assets/images/logo_waiting.gif'),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 5),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.arrow_back_ios),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35),
                                  topRight: Radius.circular(35),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                )),
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.75,
                                ),
                                child: const FormSignupWidget(),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -30,
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
