import 'package:firebase_auth/firebase_auth.dart';

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
