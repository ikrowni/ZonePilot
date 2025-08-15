import 'package:flutter/material.dart';
import '../screens/expenses_mileage_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/refer_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/summary_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'zonepilot.',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                ),
              ),
            ),
             _createDrawerItem(
              context,
              icon: Icons.receipt_long,
              text: 'Expenses', // CORRECTED TEXT
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpensesMileageScreen()),
                );
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.settings,
              text: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.bar_chart,
              text: 'Summary',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SummaryScreen()),
                );
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.share,
              text: 'Refer',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReferScreen()),
                );
              },
            ),
            _createDrawerItem(
              context,
              icon: Icons.help_outline,
              text: 'Help Center',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem(BuildContext context, {required IconData icon, required String text, required GestureTapCallback onTap}) {
    final color = Theme.of(context).textTheme.bodySmall?.color;
    return ListTile(
      leading: Icon(icon, color: color?.withAlpha(153)),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}