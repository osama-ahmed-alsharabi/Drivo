import 'package:drivo_app/features/Splash/Presentation/view/splash_view.dart';
import 'package:drivo_app/features/auth/login/presentation/view/login_view.dart';
import 'package:drivo_app/features/auth/singup/presentation/view/otp_verification_view.dart';
import 'package:drivo_app/features/auth/singup/presentation/view/singup_view.dart';
import 'package:drivo_app/features/client/home/presentation/view/client_home_view.dart';
import 'package:drivo_app/features/delivery/home_delivery/presentation/views/home_delivery_view.dart';
import 'package:drivo_app/features/service_provider/home_provider/presentation/views/home_provider.dart';
import 'package:flutter/material.dart';

abstract class AppRoutes {
  static const String splashRoute = "splashRoute";
  static const String loginRoute = "loginRoute";
  static const String singupRoute = "signupRoute";
  static const String otpVerificationRoute = "otpVerificationRoute";
  static const String clientHomeRoute = "clientHomeRoute";
  static const String homeProviderViewRoute = 'providerHomeRoute';
  static const String homeDeliveryViewRoute = "homeDeliveryViewRoute";

  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutes.splashRoute: (context) => const SplashView(),
    AppRoutes.loginRoute: (context) => const LoginView(),
    AppRoutes.singupRoute: (context) => const SignupView(),
    AppRoutes.clientHomeRoute: (context) => const ClientHomeView(),
    AppRoutes.otpVerificationRoute: (context) =>
        const OtpVerificationView(phoneNumber: ""),
    AppRoutes.homeProviderViewRoute: (context) => const HomeProviderView(),
    AppRoutes.homeDeliveryViewRoute: (context) => const HomeDeliveryView(),
  };
}
