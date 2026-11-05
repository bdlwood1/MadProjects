import 'package:firebase_auth/firebase_auth.dart';

// Keeps Firebase authentication code in one place.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Creates a new account.
  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Signs in an existing user.
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Signs out the current user.
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Watches for sign-in and sign-out changes.
  late final Stream<User?> authStateChanges = _auth.authStateChanges();

  // Returns the currently signed-in user.
  User? get currentUser => _auth.currentUser;

  // Changes the user's password.
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in.');
    }

    await user.updatePassword(newPassword);
  }

  // Reauthenticates before sensitive password changes.
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw StateError('No signed-in email account found.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }
}
