import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = '';

  // Validate and submit login details.
  Future<void> login() async {
    if (loading || !formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      await authService.signIn(email.text, password.text);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Sign-in failed. Check your email, password, or connection.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.forum_rounded,
                  size: 80,
                  color: Color(0xFF172554),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Campus Connect',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text('Sign in to your community'),
                const SizedBox(height: 30),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Enter at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                Text(error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: loading ? null : login,
                  child: Text(loading ? 'Signing in...' : 'Sign In'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
