import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Colors used throughout the app.
const Color lightBlue = Color(0xFFB7E0FA);
const Color darkBlue = Color(0xFF0055AA);
const Color cardBlue = Color(0xFFDFF3FF);
const Color backgroundBlue = Color(0xFFF0F8FF);

// Initialize Firebase before starting the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FirebaseCloudQuestApp());
}

// Main application and theme.
class FirebaseCloudQuestApp extends StatelessWidget {
  const FirebaseCloudQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Cloud Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        scaffoldBackgroundColor: backgroundBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBlue,
          foregroundColor: darkBlue,
        ),
        cardTheme: CardThemeData(
          color: cardBlue,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// Automatically switches between login and home screens.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const QuestHomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// Login and registration screen.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegistering = false;
  bool isLoading = false;
  String message = '';

  // Handles account creation and sign-in.
  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      if (isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          message = error.message ?? 'Authentication failed.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          message = 'Something went wrong: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Cloud Quest')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud, size: 85, color: darkBlue),
              const SizedBox(height: 15),
              Text(
                isRegistering ? 'Create Your Account' : 'Welcome Back!',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 25),

              // Email input.
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 15),

              // Password input.
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),

              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : authenticate,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(isRegistering ? 'Register' : 'Sign In'),
                  ),
                ),
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          isRegistering = !isRegistering;
                          message = '';
                        });
                      },
                child: Text(
                  isRegistering
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Register",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home screen displays the challenge from Firestore.
class QuestHomePage extends StatelessWidget {
  const QuestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Listen for changes to today's challenge.
    final challengeStream = FirebaseFirestore.instance
        .collection('challenges')
        .doc('today')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Cloud Quest'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: darkBlue),
            const SizedBox(height: 20),

            const Text(
              'Welcome to Cloud Quest!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Signed in as: ${user?.email ?? "Unknown"}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Read the challenge directly from Firestore.
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: challengeStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 35,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Unable to load challenge',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No challenge is available yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Extract the challenge fields.
                final data = snapshot.data!.data() ?? {};

                final title = data['title']?.toString() ?? 'Untitled Challenge';

                final description =
                    data['description']?.toString() ??
                    'No description available.';

                final points = data['points']?.toString() ?? '0';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Today's Challenge",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Icon(Icons.task_alt, color: darkBlue, size: 40),
                        const SizedBox(height: 12),

                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(description, textAlign: TextAlign.center),
                        const SizedBox(height: 15),

                        Chip(
                          avatar: const Icon(
                            Icons.stars,
                            color: darkBlue,
                            size: 18,
                          ),
                          label: Text('$points Points'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Reward interface.
            // A trusted backend must verify completion and award points.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: darkBlue,
                      size: 40,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Challenge Reward',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Complete today\'s challenge to earn '
                      'your one-time reward!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reward claiming is unavailable '
                              'until the course Firebase '
                              'backend is connected.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Challenge'),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Reward status: Not available yet',
                      style: TextStyle(color: darkBlue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AI Coach placeholder until the course gateway is available.
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.psychology, color: darkBlue, size: 35),
                    SizedBox(height: 10),

                    Text(
                      'Quest Coach',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    SizedBox(height: 12),

                    Text(
                      'AI-powered coaching will be available '
                      'when the course gateway is connected.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
