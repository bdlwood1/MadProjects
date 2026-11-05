import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'auth_gate.dart';

// Start Firebase before launching the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth INC13',

      // Orange and yellow theme for the entire app.
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),
          primary: const Color(0xFFF57C00),
          secondary: const Color(0xFFFFCA28),
          surface: const Color(0xFFFFF8E1),
        ),

        // Light cream background.
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),

        // Yellow app bars.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFCA28),
          foregroundColor: Color(0xFF5D3200),
        ),

        // Orange buttons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
        ),

        // Orange text field borders when selected.
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF57C00), width: 2),
          ),
        ),
      ),

      // Show the correct screen based on authentication status.
      home: const AuthGate(),
    );
  }
}
