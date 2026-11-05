import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

// Screen for registering and signing in.
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Orange and yellow colors used throughout the screen.
  static const Color orange = Color(0xFFF57C00);
  static const Color yellow = Color(0xFFFFCA28);
  static const Color darkBrown = Color(0xFF5D3200);

  // Validates the form and sends the request to Firebase.
  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegistering) {
        await _authService.register(email, password);
      } else {
        await _authService.signIn(email, password);
      }

      // AuthGate switches to the profile after successful login.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'This email is already registered.';
            break;
          case 'weak-password':
            _errorMessage = 'Please choose a stronger password.';
            break;
          case 'invalid-email':
            _errorMessage = 'Please enter a valid email address.';
            break;
          case 'invalid-credential':
          case 'wrong-password':
          case 'user-not-found':
            _errorMessage = 'Invalid email or password.';
            break;
          case 'network-request-failed':
            _errorMessage = 'Check your internet connection.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many attempts. Try again later.';
            break;
          default:
            _errorMessage = 'Authentication failed. Please try again.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register' : 'Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yellow circle behind the orange lock.
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: orange,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _isRegistering ? 'Create an Account' : 'Welcome Back!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isRegistering
                      ? 'Register to get started'
                      : 'Sign in to your account',
                  style: const TextStyle(fontSize: 15, color: darkBrown),
                ),

                const SizedBox(height: 28),

                // Email field with validation.
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    final email = value.trim();
                    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

                    if (!emailPattern.hasMatch(email)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field with minimum length validation.
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Displays Firebase authentication errors.
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _isRegistering ? 'Register' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Switch between registration and sign-in.
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                            _errorMessage = null;
                            _formKey.currentState?.reset();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : 'Need an account? Register',
                    style: const TextStyle(
                      color: orange,
                      fontWeight: FontWeight.bold,
                    ),
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
