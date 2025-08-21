import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import TTS
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
  // Define the communication channel and TTS plugin
  static const platform = MethodChannel('com.example.zone_pilot/accessibility_service');
  final FlutterTts flutterTts = FlutterTts();

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

  // --- THIS IS THE UPDATED GO/STOP LOGIC ---
  void _toggleOnlineStatus() async {
    if (!_isOnline) {
      // GO ONLINE SEQUENCE
      setState(() => _isOnline = true);
      await LaunchApp.openApp(androidPackageName: 'com.ubercab.driver');
      await Future.delayed(const Duration(seconds: 2));
      try {
        await platform.invokeMethod('goOnline');
        await flutterTts.speak("Uber is online");
      } on PlatformException catch (e) {
        print("Failed to go online: '${e.message}'.");
        await flutterTts.speak("Error going online");
        if (mounted) setState(() => _isOnline = false); // Revert state on error
      }
    } else {
      // GO OFFLINE SEQUENCE
      setState(() => _isOnline = false);
      // Bring Uber to the front first to ensure the service can see it
      await LaunchApp.openApp(androidPackageName: 'com.ubercab.driver');
      await Future.delayed(const Duration(seconds: 2));
      try {
        await platform.invokeMethod('goOffline');
        await flutterTts.speak("Uber is offline");
      } on PlatformException catch (e) {
        print("Failed to go offline: '${e.message}'.");
        await flutterTts.speak("Error going offline");
        if (mounted) setState(() => _isOnline = true); // Revert state on error
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
              color: Colors.white,
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