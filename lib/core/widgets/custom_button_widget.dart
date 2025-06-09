import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String? text;
  final Color? color;
  final void Function()? onTap;
  final Widget? widget;
  const CustomButtonWidget({
    super.key,
    this.text,
    this.color,
    this.onTap,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
            color: color ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor,
            )),
        child: widget ??
            Text(
              text ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}
