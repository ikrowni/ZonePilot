import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone_pilot/screens/auth_gate.dart';
import 'package:zone_pilot/services/theme_notifier.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final themeModeName = prefs.getString('themeMode') ?? 'system';
  final themeMode = ThemeMode.values.byName(themeModeName);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(themeMode),
      child: const ZonePilotApp(),
    ),
  );
}

// RESTORED the full AppColors class
class AppColors {
  static const Color primaryOrange = Color(0xFFF36F2E);
  static const Color background = Colors.black;
  static const Color cardBackground = Color(0xFF1C1C1E);
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFF8A8A8E);
  static const Color inactive = Color(0xFF757575);
}

class ZonePilotApp extends StatelessWidget {
  const ZonePilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
       brightness: Brightness.dark,
       scaffoldBackgroundColor: AppColors.background,
       fontFamily: 'Roboto',
       colorScheme: const ColorScheme.dark(
         primary: AppColors.primaryOrange,
         secondary: AppColors.primaryOrange,
         surface: AppColors.cardBackground,
         onSurface: AppColors.primaryText,
       ),
       cardTheme: CardThemeData(
         color: AppColors.cardBackground,
         elevation: 0,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12.0),
         ),
       ),
       appBarTheme: const AppBarTheme(
           backgroundColor: AppColors.background,
           elevation: 0,
           iconTheme: IconThemeData(color: AppColors.primaryText),
           titleTextStyle: TextStyle(
             color: AppColors.primaryText,
             fontSize: 22,
             fontWeight: FontWeight.bold,
           )),
       elevatedButtonTheme: ElevatedButtonThemeData(
         style: ElevatedButton.styleFrom(
           backgroundColor: AppColors.primaryOrange,
           foregroundColor: AppColors.primaryText,
           shape: const StadiumBorder(),
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
         ),
       ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      fontFamily: 'Roboto',
      primaryColor: AppColors.primaryOrange,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryOrange,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      cardTheme: CardThemeData( // CORRECTED to CardThemeData
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
    
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'ZonePilot',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.getThemeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}