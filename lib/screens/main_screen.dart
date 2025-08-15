import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/service_model.dart';
import '../screens/drive_screen.dart';
import '../screens/history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isOnline = false;
  static const platform = MethodChannel('com.zonepilot/accessibility');

  final List<Service> _services = [
    Service(
      name: 'Uber',
      imagePath: 'assets/images/uber_logo.png',
      androidPackageName: 'com.ubercab.driver',
      isEnabled: true,
    ),
    Service(
      name: 'DoorDash',
      imagePath: 'assets/images/doordash_logo.png',
      androidPackageName: 'com.doordash.driverapp',
      isEnabled: false,
    ),
  ];

  void _handleServiceToggle(String serviceName, bool isEnabled) {
    setState(() {
      final service = _services.firstWhere((s) => s.name == serviceName);
      service.isEnabled = isEnabled;
    });
  }

  void _toggleOnlineStatus() async {
    // First, toggle the state of our button so the UI feels responsive
    setState(() {
      _isOnline = !_isOnline;
    });

    if (_isOnline) {
      // GO ONLINE LOGIC (unchanged)
      for (final service in _services) {
        if (service.isEnabled) {
          await LaunchApp.openApp(androidPackageName: service.androidPackageName);
        }
      }
    } else {
      // GO OFFLINE LOGIC (UPDATED)
      try {
        // 1. Bring the Uber app to the foreground.
        await LaunchApp.openApp(androidPackageName: 'com.ubercab.driver');
        // 2. Give the app a moment to launch and settle.
        await Future.delayed(const Duration(seconds: 2));
        // 3. Now, send the command to the service, which is looking at the correct screen.
        await platform.invokeMethod('goOffline');
      } on PlatformException catch (e) {
        print("Failed to go offline: '${e.message}'.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      DriveScreen(
        services: _services,
        onServiceToggle: _handleServiceToggle,
      ),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          onPressed: _toggleOnlineStatus,
          backgroundColor: _isOnline ? Colors.red.shade700 : Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: Text(
            _isOnline ? 'STOP' : 'GO',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).cardTheme.color,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(context, Icons.drive_eta, 'Drive', 0),
            const SizedBox(width: 40),
            _buildNavItem(context, Icons.history, 'History', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
