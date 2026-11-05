import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

// Protected screen shown only after signing in.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  // Colors used for the orange and yellow theme.
  static const Color orange = Color(0xFFF57C00);
  static const Color yellow = Color(0xFFFFCA28);
  static const Color darkBrown = Color(0xFF5D3200);

  // Changes the password after checking the current password.
  Future<void> _changePassword() async {
    if (_isLoading || !_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Firebase requires a recent login for sensitive changes.
      await _authService.reauthenticate(_currentPasswordController.text);

      await _authService.changePassword(_newPasswordController.text);

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();

      setState(() {
        _message = 'Password updated successfully!';
        _isError = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Current password is incorrect.';
          break;
        case 'weak-password':
          errorMessage = 'Choose a stronger new password.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign in again before changing your password.';
          break;
        case 'network-request-failed':
          errorMessage = 'Check your internet connection.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;
        default:
          errorMessage = 'Could not update password. Try again.';
      }

      setState(() {
        _message = errorMessage;
        _isError = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message = 'Something went wrong. Please try again.';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Signs out and returns to the authentication screen.
  Future<void> _signOut() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.signOut();
      // AuthGate automatically displays the sign-in screen.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message = 'Could not sign out. Please try again.';
        _isError = true;
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Yellow circle with an orange profile icon.
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    size: 72,
                    color: orange,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Signed in as:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: darkBrown),
              ),

              const SizedBox(height: 8),

              // Shows the currently signed-in user's email.
              Text(
                user?.email ?? 'No email available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: yellow, thickness: 2),
              const SizedBox(height: 24),

              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 20),

              // Current password is used for reauthentication.
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // New password must meet the minimum length.
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.key_outlined),
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

              // Shows password update success or error messages.
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isError ? Colors.red : Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text(
                      'Update Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Sign-out button with orange border.
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: orange,
                  side: const BorderSide(color: orange, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
