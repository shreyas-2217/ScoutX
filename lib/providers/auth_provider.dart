import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/database.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final Database _db;

  User? _user;
  UserProfile? _profile;
  bool _loadingProfile = false;
  String? _error;

  AuthProvider(this._authService, this._db) {
    _authService.userStream.listen((user) {
      _user = user;
      if (user == null) {
        _profile = null;
        _error = null;
        _loadingProfile = false;
        notifyListeners();
      } else {
        _loadProfile(user.uid);
      }
    });
  }

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoggedIn => _user != null;
  bool get loadingProfile => _loadingProfile;
  String? get error => _error;

  Future<void> _loadProfile(String uid) async {
    _loadingProfile = true;
    notifyListeners();
    try {
      await _db.syncClipCount(uid);
    } catch (_) {}
    try {
      _profile = await _db.getUserProfile(uid);
    } catch (e) {
      _profile = null;
    }
    // No Firestore profile yet — registration may have been interrupted
    // before the profile write finished, or the profile was deleted
    // server-side. Keep the auth session and let HomeGate route to
    // CompleteProfileScreen so the user can finish setup. Signing out here
    // would trap freshly registered users: login loops back here and
    // re-registering fails with email-already-in-use.
    _loadingProfile = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_user == null) return;
    await _db.syncClipCount(_user!.uid);
    _profile = await _db.getUserProfile(_user!.uid);
    notifyListeners();
  }

  void setProfileDirectly(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Connection timed out. Check your internet and try again.');
      });
    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    _error = null;
    notifyListeners();
    try {
      await _authService.signInWithGoogle()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Google sign-in timed out. Please try again.');
      });
    } on FirebaseAuthException catch (e) {
      // User closed the popup or cancelled — not an error worth showing.
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        notifyListeners();
        return;
      }
      _error = _friendlyAuthError(e.code);
      if (e.code == 'operation-not-allowed') {
        _error =
            'Google sign-in is not enabled yet. Enable the Google provider in '
            'Firebase Console → Authentication → Sign-in method.';
      }
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Could not start Google sign-in. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? sport,
    String? position,
    String? teamName,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    _error = null;
    notifyListeners();
    try {
      // Sign out any existing user first (fire and forget)
      _authService.signOut().catchError((_) {});

      final user = await _authService.signUp(email, password)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Connection timed out. Check your internet and try again.');
      });
      final profile = UserProfile(
        uid: user.uid,
        email: email.trim(),
        role: role,
        displayName: displayName.trim(),
        sport: sport,
        position: position,
        teamName: teamName,
        city: city,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );
      try {
        await _db.createUserProfile(profile)
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Firestore write failed — profile will be created on first login via CompleteProfileScreen
      }
      _profile = profile;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception: ', '')
          : 'An unexpected error occurred. Please try again.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;
    await _db.updateUserProfile(_user!.uid, updates);
    await refreshProfile();
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('AuthProvider signOut error: $e');
    }
    _user = null;
    _profile = null;
    _error = null;
    _loadingProfile = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _db.deleteAccount(uid);
    await _authService.deleteCurrentUser();
    _profile = null;
    _user = null;
    notifyListeners();
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a password. '
            'Sign in with your password to connect Google.';
      case 'popup-blocked':
        return 'Your browser blocked the sign-in popup. Allow popups and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
