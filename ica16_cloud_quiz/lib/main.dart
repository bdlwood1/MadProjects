import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

const purple = Color(0xFF6933B8);
const pink = Color(0xFFE95C9E);
const backgroundPink = Color(0xFFFFF0F8);
const lavender = Color(0xFFF1E7FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud Quiz',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundPink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: pink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

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

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const QuizScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          error = e.message ?? 'Unable to sign in.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud, color: purple, size: 65),
                  const SizedBox(height: 12),
                  const Text(
                    'Cloud Quiz',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to play and save your score!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: loading ? null : signIn,
                    child: Text(loading ? 'Signing in...' : 'Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// One validated question with four unique answer choices.
class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> choices;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.choices,
  });
}

enum QuizStage {
  loading,
  ready,
  playing,
  finished,
  saving,
  saveUnknown,
  verifying,
  verified,
  error,
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final firestore = FirebaseFirestore.instance;
  final unescape = HtmlUnescape();

  List<QuizQuestion> questions = [];
  List<String?> selections = [];

  QuizStage stage = QuizStage.loading;
  int currentIndex = 0;
  String? roundId;
  String message = '';
  bool busy = false;
  DateTime? lastRequestAt;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  int get score {
    int total = 0;

    for (int i = 0; i < selections.length; i++) {
      if (selections[i] == questions[i].correctAnswer) {
        total++;
      }
    }

    return total;
  }

  // OpenTDB requires rate-limited requests and valid API responses.
  Future<void> loadQuestions() async {
    if (busy) return;

    final previousRequest = lastRequestAt;

    if (previousRequest != null) {
      final elapsed = DateTime.now().difference(previousRequest);

      if (elapsed < const Duration(seconds: 5)) {
        setState(() {
          stage = QuizStage.error;
          message = 'Please wait five seconds before trying again.';
        });
        return;
      }
    }

    setState(() {
      busy = true;
      stage = QuizStage.loading;
      message = '';
    });

    lastRequestAt = DateTime.now();

    try {
      final uri = Uri.parse(
        'https://opentdb.com/api.php'
        '?amount=10&category=9&difficulty=easy&type=multiple',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP error ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['response_code'] != 0 ||
          decoded['results'] is! List) {
        throw Exception('Question service returned an invalid response.');
      }

      final raw = decoded['results'] as List;

      if (raw.length != 10) {
        throw Exception('Expected exactly 10 questions.');
      }

      final parsed = <QuizQuestion>[];
      final random = Random();

      for (final item in raw) {
        if (item is! Map<String, dynamic> ||
            item['category'] != 'General Knowledge' ||
            item['difficulty'] != 'easy' ||
            item['type'] != 'multiple' ||
            item['question'] is! String ||
            item['correct_answer'] is! String ||
            item['incorrect_answers'] is! List) {
          throw Exception('Invalid question data.');
        }

        final incorrect = item['incorrect_answers'] as List;

        if (incorrect.length != 3 ||
            incorrect.any((answer) => answer is! String)) {
          throw Exception('Invalid answer choices.');
        }

        final question = unescape.convert(item['question'] as String);
        final correct = unescape.convert(item['correct_answer'] as String);

        final choices = [
          correct,
          ...incorrect.map((answer) {
            return unescape.convert(answer as String);
          }),
        ];

        if (question.trim().isEmpty ||
            choices.any((answer) => answer.trim().isEmpty) ||
            choices.toSet().length != 4) {
          throw Exception('Empty or duplicate answer choices.');
        }

        choices.shuffle(random);

        parsed.add(
          QuizQuestion(
            question: question,
            correctAnswer: correct,
            choices: choices,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        questions = parsed;
        selections = List<String?>.filled(10, null);
        currentIndex = 0;
        roundId = firestore.collection('attempts').doc().id;
        stage = QuizStage.ready;
        message = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        stage = QuizStage.error;
        message = 'Could not load questions: $e';
      });
    } finally {
      busy = false;
    }
  }

  void chooseAnswer(String answer) {
    if (stage != QuizStage.playing || selections[currentIndex] != null) {
      return;
    }

    setState(() {
      selections[currentIndex] = answer;
    });
  }

  void nextQuestion() {
    if (selections[currentIndex] == null) return;

    setState(() {
      if (currentIndex == 9) {
        stage = QuizStage.finished;
      } else {
        currentIndex++;
      }
    });
  }

  DocumentReference<Map<String, dynamic>> get attemptRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return firestore
        .collection('users')
        .doc(uid)
        .collection('attempts')
        .doc(roundId!);
  }

  Map<String, dynamic> get attemptPayload {
    return {
      'schemaVersion': 1,
      'variant': 'A',
      'categoryId': 9,
      'questionCount': 10,
      'correctCount': score,
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }

  // Compare the five immutable fields, excluding server timestamp.
  bool matchesPayload(Map<String, dynamic> data) {
    return data.length == 6 &&
        data['schemaVersion'] == 1 &&
        data['variant'] == 'A' &&
        data['categoryId'] == 9 &&
        data['questionCount'] == 10 &&
        data['correctCount'] == score &&
        data['submittedAt'] is Timestamp;
  }

  // A server-only read is required before claiming cloud success.
  Future<bool> verifyFromServer() async {
    final snapshot = await attemptRef.get(
      const GetOptions(source: Source.server),
    );

    if (!snapshot.exists || snapshot.metadata.hasPendingWrites) {
      return false;
    }

    final data = snapshot.data();

    return data != null && matchesPayload(data);
  }

  Future<void> saveAttempt() async {
    if (busy || roundId == null) return;

    setState(() {
      busy = true;
      stage = QuizStage.saving;
      message = 'Saving your result...';
    });

    final expected = {
      'schemaVersion': 1,
      'variant': 'A',
      'categoryId': 9,
      'questionCount': 10,
      'correctCount': score,
    };

    try {
      // Transaction retries use the SAME document ID.
      await firestore
          .runTransaction((transaction) async {
            final existing = await transaction.get(attemptRef);

            if (existing.exists) {
              final data = existing.data();

              if (data == null || !matchesPayload(data)) {
                throw StateError(
                  'This round ID already has a different result.',
                );
              }

              return;
            }

            transaction.set(attemptRef, {
              ...expected,
              'submittedAt': FieldValue.serverTimestamp(),
            });
          })
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        stage = QuizStage.verifying;
        message = 'Checking the saved document on the server...';
      });

      final verified = await verifyFromServer();

      if (!mounted) return;

      setState(() {
        stage = verified ? QuizStage.verified : QuizStage.saveUnknown;

        message = verified
            ? 'Cloud verified! Your score was saved.'
            : 'Verification unavailable. Check the server before retrying.';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        stage = QuizStage.saveUnknown;
        message =
            'Cloud save not confirmed (${e.code}). '
            'Use Verify / Retry to check the server.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        stage = QuizStage.saveUnknown;
        message = 'Save status unknown: $e';
      });
    } finally {
      busy = false;
    }
  }

  // First check the server, then retry the same round if needed.
  Future<void> reconcileAttempt() async {
    if (busy) return;

    setState(() {
      busy = true;
      stage = QuizStage.verifying;
      message = 'Checking the server...';
    });

    try {
      final snapshot = await attemptRef.get(
        const GetOptions(source: Source.server),
      );

      if (snapshot.exists) {
        if (snapshot.data() == null || !matchesPayload(snapshot.data()!)) {
          throw StateError('Saved document does not match this round.');
        }

        if (!mounted) return;

        setState(() {
          stage = QuizStage.verified;
          message = 'Cloud verified! Existing attempt recovered.';
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        stage = QuizStage.saveUnknown;
        message = 'No matching server document found.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        stage = QuizStage.saveUnknown;
        message = 'Verification unavailable: $e';
      });
    } finally {
      busy = false;
    }
  }

  Future<void> replay() async {
    if (busy ||
        stage == QuizStage.saving ||
        stage == QuizStage.verifying ||
        stage == QuizStage.saveUnknown) {
      return;
    }

    await loadQuestions();
  }

  Widget quizCard({required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget buildReady() {
    return quizCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.quiz, size: 75, color: purple),
          const SizedBox(height: 15),
          const Text(
            'Ready for your quiz?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '10 easy General Knowledge questions.\n'
            'Each correct answer earns 1 point.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              setState(() => stage = QuizStage.playing);
            },
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }

  Widget buildQuestion() {
    final question = questions[currentIndex];
    final selected = selections[currentIndex];

    return quizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${currentIndex + 1} of 10',
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (currentIndex + 1) / 10,
            color: pink,
            backgroundColor: lavender,
          ),
          const SizedBox(height: 24),
          Text(
            question.question,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          for (final answer in question.choices) ...[
            OutlinedButton(
              onPressed: selected == null ? () => chooseAnswer(answer) : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: selected == null
                    ? lavender
                    : answer == question.correctAnswer
                    ? Colors.green.shade100
                    : answer == selected
                    ? Colors.red.shade100
                    : Colors.white,
                disabledForegroundColor: Colors.black87,
              ),
              child: Text(answer),
            ),
            const SizedBox(height: 9),
          ],
          if (selected != null) ...[
            const SizedBox(height: 12),
            Text(
              selected == question.correctAnswer
                  ? '✓ Correct!'
                  : '✗ Incorrect. Answer: ${question.correctAnswer}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected == question.correctAnswer
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: nextQuestion,
              child: Text(currentIndex == 9 ? 'See Results' : 'Next Question'),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildResults() {
    return quizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.emoji_events, color: pink, size: 65),
          const SizedBox(height: 12),
          const Text(
            'Quiz Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
              fontSize: 27,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 10',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: pink,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Answer Review',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < questions.length; i++) ...[
            Text(
              '${i + 1}. ${questions[i].question}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Your answer: ${selections[i]}'),
            Text('Correct answer: ${questions[i].correctAnswer}'),
            const Divider(),
          ],
          const SizedBox(height: 12),
          if (message.isNotEmpty)
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
          if (stage == QuizStage.finished)
            FilledButton(
              onPressed: saveAttempt,
              child: const Text('Save Score to Cloud'),
            ),
          if (stage == QuizStage.saveUnknown)
            FilledButton(
              onPressed: reconcileAttempt,
              child: const Text('Verify / Retry'),
            ),
          if (stage == QuizStage.saveUnknown)
            const Text(
              'This checks the server first. If the save is missing, '
              'return to the result and retry with the same round ID.',
              textAlign: TextAlign.center,
            ),
          if (stage == QuizStage.verified)
            const Text(
              '✓ CLOUD VERIFIED',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          if (stage == QuizStage.verified)
            OutlinedButton(
              onPressed: reconcileAttempt,
              child: const Text('Verify Again'),
            ),
          if (stage == QuizStage.verified)
            FilledButton(onPressed: replay, child: const Text('Play Again')),
          if (stage == QuizStage.saving || stage == QuizStage.verifying)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Quiz'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed:
                busy ||
                    stage == QuizStage.saving ||
                    stage == QuizStage.verifying ||
                    stage == QuizStage.saveUnknown
                ? null
                : () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lavender,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'GENERAL KNOWLEDGE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: purple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Signed in: ${user?.email ?? "Unknown"}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (stage == QuizStage.loading)
              quizCard(
                child: const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading questions...'),
                  ],
                ),
              )
            else if (stage == QuizStage.error)
              quizCard(
                child: Column(
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: loadQuestions,
                      child: const Text('Retry Loading'),
                    ),
                  ],
                ),
              )
            else if (stage == QuizStage.ready)
              buildReady()
            else if (stage == QuizStage.playing)
              buildQuestion()
            else
              buildResults(),
          ],
        ),
      ),
    );
  }
}
