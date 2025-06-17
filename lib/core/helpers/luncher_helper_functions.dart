import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LuncherHelperFunctions {
  Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'لا يمكن فتح تطبيق الهاتف';
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.fail,
          label: "لا يمكن إجراء المكالمة");
    }
  }

  Future<void> openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      final url = "https://wa.me/$phoneNumber";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web version
        await launchUrl(
          Uri.parse("https://web.whatsapp.com/send?phone=$phoneNumber"),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomSnackbar(
          context: context,
          snackBarType: SnackBarType.fail,
          label: "لا يمكن فتح واتساب");
    }
  }
}
