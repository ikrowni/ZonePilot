import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // Using AppColors

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
      }
      // No need to set isLoading back to false on success, as the widget will be removed
    } on FirebaseAuthException catch (e) {
      // ADD THIS CHECK: If the widget is no longer on screen, do nothing.
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Zone Pilot',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 32),
                if (_isLoading) const CircularProgressIndicator(),
                if (!_isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Sign Up'),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!_isLoading)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Create an account'
                          : 'I already have an account',
                      style: const TextStyle(color: AppColors.primaryOrange),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}