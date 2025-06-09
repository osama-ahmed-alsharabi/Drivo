import 'package:drivo_app/features/service_provider/dashboard/presentation/view/widgets/quick_action_widget.dart';
import 'package:drivo_app/features/service_provider/dashboard/presentation/view/widgets/state_card_provider_widget.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('لوحة التحكم'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StateCardProviderWidget(),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return const QuickActionWidget();
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
