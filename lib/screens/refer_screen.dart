import 'package:flutter/material.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer a Friend'),
        centerTitle: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Referral Program Information Goes Here.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}