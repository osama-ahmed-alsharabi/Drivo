import 'package:flutter/material.dart';

class ClientListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ClientListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
