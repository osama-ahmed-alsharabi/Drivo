import 'package:flutter/material.dart';

class QuickActionButtonWidget extends StatelessWidget {
  final void Function()? onTap;
  final IconData icon;
  final String label;
  const QuickActionButtonWidget(
      {super.key, this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Icon(icon, color: Theme.of(context).secondaryHeaderColor),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
