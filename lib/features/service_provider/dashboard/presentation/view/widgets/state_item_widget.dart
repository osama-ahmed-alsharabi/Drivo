import 'package:flutter/material.dart';

class StateItemWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  const StateItemWidget(
      {super.key,
      required this.icon,
      required this.value,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).secondaryHeaderColor),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
