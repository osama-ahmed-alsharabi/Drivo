import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/core/widgets/custom_button_widget.dart';
import 'package:drivo_app/features/auth/login/presentation/view/login_view.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/client_profile_header_widget.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/client_settings_section.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/client_support_section.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/logout_button_widget.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/order_section.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _loadData() async {
    final userName = await SharedPreferencesService.getUserName();
    return {
      'user_name': userName,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
            future: _loadData(),
            builder: (context, snapShot) {
              final userName = snapShot.data?['user_name'];
              if (userName != null) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClientProfileHeaderWidget(),
                    SizedBox(height: 24),
                    ClientOrderSection(),
                    SizedBox(height: 24),
                    ClientSettingsSection(),
                    SizedBox(height: 24),
                    ClientSupportSection(),
                    SizedBox(height: 24),
                    LogoutButtonWidget(),
                    SizedBox(height: 24),
                  ],
                );
              } else if (!snapShot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Column(
                  children: [
                    Image.asset(AppImages.userNotFound),
                    CustomButtonWidget(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()));
                      },
                      text: "قم بتسجيل الدخول",
                    )
                  ],
                );
              }
            }),
      ),
    );
  }
}
