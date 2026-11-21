import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Track login and logout changes.
  late final Stream<User?> authState = _auth.authStateChanges();

  // Register a user and create their Firestore profile.
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await result.user!.updateDisplayName('$firstName $lastName');

    await _db.collection('users').doc(result.user!.uid).set({
      'uid': result.user!.uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'role': 'user',
      'registrationDateTime': FieldValue.serverTimestamp(),
    });
  }

  // Sign in with email and password.
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // End the current session.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authService = AuthService();
