import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/core/routes/app_routes.dart';
import 'package:drivo_app/features/auth/login/presentation/view/widgets/form_login_widget.dart';
import 'package:drivo_app/features/auth/login/presentation/view_model/cubit/login_cubit.dart';
import 'package:drivo_app/features/auth/login/presentation/view_model/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: BlocProvider(
        create: (context) => LoginCubit(),
        child: Builder(builder: (context) {
          return BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                CustomSnackbar(
                  context: context,
                  snackBarType: SnackBarType.fail,
                  label: state.error,
                );
              } else if (state is LoginSuccessClient) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.clientHomeRoute,
                  (route) => false,
                );
              } else if (state is LoginSuccessPorvider) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homeProviderViewRoute,
                  (route) => false,
                );
              } else if (state is LoginSuccessDelivery) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.homeDeliveryViewRoute,
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              return ModalProgressHUD(
                inAsyncCall: state is LoginLoading,
                opacity: 1,
                color: Theme.of(context).primaryColor,
                progressIndicator: Center(
                  child: Image.asset('assets/images/logo_waiting.gif'),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.75,
                                ),
                                child: const FormLoginWidget(),
                              ),
                            ),
                            Positioned(
                              top: -30,
                              left:
                                  (MediaQuery.of(context).size.width / 2) - 35,
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
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
