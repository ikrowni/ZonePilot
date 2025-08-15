import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zone_pilot/screens/auth_screen.dart';
import 'package:zone_pilot/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is not logged in, show the authentication screen
        if (!snapshot.hasData) {
          return const AuthScreen();
        }

        // If the user is logged in, show the main app screen
        return const MainScreen();
      },
    );
  }
}