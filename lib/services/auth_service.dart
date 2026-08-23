import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userStream => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  /// Google sign-in via Firebase. Uses a popup flow on web (handled entirely
  /// by the Firebase JS SDK, no extra packages or OAuth client setup).
  Future<User> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final UserCredential cred;
    if (kIsWeb) {
      cred = await _auth.signInWithPopup(provider);
    } else {
      cred = await _auth.signInWithProvider(provider);
    }
    return cred.user!;
  }

  /// Signs in with email/password and links the pending [googleCredential]
  /// (from an `account-exists-with-different-credential` conflict) to that
  /// account, so future Google sign-ins go straight through.
  Future<User> linkGoogleCredential(
    String email,
    String password,
    AuthCredential googleCredential,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.linkWithCredential(googleCredential);
    return cred.user!;
  }

  Future<User> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
