import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zone_pilot/models/service_model.dart';
import 'package:zone_pilot/screens/summary_screen.dart';
import 'package:zone_pilot/widgets/app_drawer.dart';
import 'package:zone_pilot/widgets/service_card.dart';

// This is now a StatelessWidget again
class DriveScreen extends StatelessWidget {
  final List<Service> services;
  final Function(String, bool) onServiceToggle;

  const DriveScreen({
    super.key,
    required this.services,
    required this.onServiceToggle,
  });
  
  // The MethodChannel is defined here only for the Dump Layout button
  static const platform = MethodChannel('com.example.zone_pilot/accessibility_service');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Zone Pilot'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Padding for FAB
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.bug_report_outlined),
            label: const Text('Dump Layout to Logcat'),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Switch to your target app now... Dumping in 5 seconds.'),
                  backgroundColor: Colors.blue,
                ),
              );
              await Future.delayed(const Duration(seconds: 5));
              try {
                final String? result = await platform.invokeMethod('dumpLayout');
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(result ?? 'Layout dumped! Check Logcat.'),
                    backgroundColor: Colors.green[700],
                  ),
                );
              } on PlatformException catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("Failed to dump layout: ${e.message}"),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          Text('Enabled Services', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...services.map((service) {
            return ServiceCard(
              service: service,
              onToggleChanged: (isEnabled) {
                onServiceToggle(service.name, isEnabled);
              },
            );
          }),
        ],
      ),
    );
  }
}