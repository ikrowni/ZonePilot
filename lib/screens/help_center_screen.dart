import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Help and Support Information Goes Here.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}