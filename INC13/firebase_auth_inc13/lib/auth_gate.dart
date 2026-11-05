import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'authentication_screen.dart';
import 'profile_screen.dart';

// Chooses the correct screen based on Firebase sign-in status.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show a loading indicator while checking authentication.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show an error if Firebase cannot check authentication.
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to check sign-in status. Try again.'),
            ),
          );
        }

        // Signed-in users see their protected profile.
        if (snapshot.data != null) {
          return const ProfileScreen();
        }

        // Signed-out users see the authentication form.
        return const AuthenticationScreen();
      },
    );
  }
}
