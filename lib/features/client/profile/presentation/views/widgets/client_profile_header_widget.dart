import 'package:drivo_app/core/service/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ClientProfileHeaderWidget extends StatelessWidget {
  const ClientProfileHeaderWidget({super.key});
  Future<Map<String, dynamic>> _loadData() async {
    final phoneNumber = await SharedPreferencesService.getUserPhone() ?? 0;
    final userName = await SharedPreferencesService.getUserName() ?? 0;
    final email = await SharedPreferencesService.getEmail() ?? 0;
    return {
      'phone_number': phoneNumber,
      'user_name': userName,
      'email': email,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          final phoneNumber = snapshot.data?['phone_number'] ?? 0;
          final userName = snapshot.data?['user_name'] ?? "";
          final email = snapshot.data?['email'] ?? "";
          return Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                child: Icon(
                  IconlyBold.profile,
                  size: 40,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phoneNumber.toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
