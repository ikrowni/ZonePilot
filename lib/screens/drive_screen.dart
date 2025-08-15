import 'package:flutter/material.dart';
import '../models/service_model.dart'; // Import the Service model
import '../screens/summary_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/service_card.dart';

class DriveScreen extends StatelessWidget {
  final List<Service> services;
  final Function(String, bool) onServiceToggle;

  const DriveScreen({
    super.key,
    required this.services,
    required this.onServiceToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Zone Pilot',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SummaryScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Session Summary', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Enabled', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          
          ...services.map((service) {
            return ServiceCard(
              service: service,
              onToggleChanged: (isEnabled) {
                onServiceToggle(service.name, isEnabled);
              },
            );
          }),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
