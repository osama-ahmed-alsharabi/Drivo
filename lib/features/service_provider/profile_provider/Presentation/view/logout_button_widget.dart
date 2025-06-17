import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/features/auth/login/presentation/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class LogoutButtonWidgetServiceProvider extends StatelessWidget {
  const LogoutButtonWidgetServiceProvider({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await SharedPreferencesService.clearEmail();
              await SharedPreferencesService.clearUser();
              await SharedPreferencesService.clearUserId();
              await SharedPreferencesService.clearUserPhone();
              await SharedPreferencesService.clearUserType();
              await SharedPreferencesService.clearProducts();
              await SharedPreferencesService.clearOffers();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyBold.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
