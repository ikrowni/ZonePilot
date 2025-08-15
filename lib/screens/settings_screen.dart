import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';
import '../main.dart';
import '../services/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _userId;
  // NEW: Communication channel and service status
  static const platform = MethodChannel('com.zonepilot/accessibility');
  bool _isAccessibilityServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    // NEW: Set up the handler to listen for messages from the native service
    platform.setMethodCallHandler(_handleMethodCall);
  }

  // NEW: Handler for incoming messages from native code
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'serviceConnected':
        setState(() {
          _isAccessibilityServiceEnabled = true;
        });
        break;
      case 'serviceDestroyed':
         setState(() {
          _isAccessibilityServiceEnabled = false;
        });
        break;
      default:
        // ignore: avoid_print
        print('Unknown method ${call.method}');
    }
  }
  
  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _showThemeDialog(ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeNotifier.getThemeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeNotifier.getThemeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeNotifier.getThemeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Permissions'),
          _buildTappableRow(context, 
            icon: Icons.location_on, 
            title: 'Location',
            onTap: () => AppSettings.openAppSettings(type: AppSettingsType.location)
          ),
           _buildTappableRow(context, 
            icon: Icons.notifications, 
            title: 'Notifications',
            onTap: () => AppSettings.openAppSettings(type: AppSettingsType.notification)
          ),
          _buildTappableRow(context, 
            icon: Icons.accessibility, 
            title: 'Accessibility Service',
            subtitle: _isAccessibilityServiceEnabled ? 'Enabled' : 'Disabled',
            onTap: () => AppSettings.openAppSettings(type: AppSettingsType.accessibility)
          ),
          _buildTappableRow(context, 
            icon: Icons.settings_applications, 
            title: 'System Settings',
            onTap: () => AppSettings.openAppSettings(type: AppSettingsType.settings)
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Gig Apps'),
          _buildTappableRow(context, iconWidget: const FaIcon(FontAwesomeIcons.uber, size: 20), title: 'Uber - Offline'),
          _buildTappableRow(context, iconWidget: const FaIcon(FontAwesomeIcons.boxOpen, size: 20), title: 'DoorDash - Offline'),
          
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Preferences'),
          _buildTappableRow(context, 
            icon: Icons.brightness_6, 
            title: 'Dark Mode',
            subtitle: 'Current: ${_getThemeModeText(themeNotifier.getThemeMode)}',
            onTap: () => _showThemeDialog(themeNotifier),
          ),
          _buildTappableRow(context, icon: Icons.subscriptions, title: 'Subscription'),
          _buildTappableRow(context, icon: Icons.share, title: 'Share Zone Pilot'),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Account'),
          _buildTappableRow(context, icon: Icons.person, title: 'User ID', subtitle: _userId),
          _buildTappableRow(context, icon: Icons.logout, title: 'Logout', titleColor: Colors.red, onTap: _logout),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTappableRow(BuildContext context,
      {IconData? icon,
      Widget? iconWidget,
      required String title,
      String? subtitle,
      Color? titleColor,
      VoidCallback? onTap}) {
    
    final Color secondaryTextColor = Theme.of(context).brightness == Brightness.dark ? AppColors.secondaryText : Colors.grey.shade600;

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            if (iconWidget != null) 
              SizedBox(width: 24, child: Center(child: iconWidget)),
            if (icon != null) 
              SizedBox(width: 24, child: Center(child: Icon(icon, color: secondaryTextColor))),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                ),
              ),
            ),
            if (subtitle != null)
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondaryTextColor),
                ),
              )
            else
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }
}
