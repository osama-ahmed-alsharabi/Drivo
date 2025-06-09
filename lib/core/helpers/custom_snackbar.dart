import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class CustomSnackbar {
  CustomSnackbar(
      {required BuildContext context,
      required SnackBarType snackBarType,
      required String label}) {
    IconSnackBar.show(
      behavior: SnackBarBehavior.floating,
      maxLines: 2,
      direction: DismissDirection.up,
      context,
      snackBarType: snackBarType,
      label: label,
    );
  }
}
