import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = '';

  // Create the account and user profile.
  Future<void> register() async {
    if (loading || !formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      await authService.register(
        email: email.text,
        password: password.text,
        firstName: firstName.text,
        lastName: lastName.text,
      );

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              error = 'Registration failed. Check your details or connection.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Widget field(
    TextEditingController controller,
    String label, {
    bool secret = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: secret,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Enter a valid email';
          }
          if (secret && value.length < 6) {
            return 'Use at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 70),
              const SizedBox(height: 20),
              field(firstName, 'First Name'),
              field(lastName, 'Last Name'),
              field(email, 'Email'),
              field(password, 'Password', secret: true),
              Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: loading ? null : register,
                child: Text(loading ? 'Creating account...' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
