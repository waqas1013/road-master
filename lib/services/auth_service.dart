import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    notifyListeners();
    return credential;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
    }
    notifyListeners();
    return credential;
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Inget konto hittades med den e-postadressen.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Fel lösenord. Försök igen.';
      case 'email-already-in-use':
        return 'E-postadressen är redan registrerad.';
      case 'weak-password':
        return 'Lösenordet är för svagt. Minst 6 tecken.';
      case 'invalid-email':
        return 'Ogiltig e-postadress.';
      case 'too-many-requests':
        return 'För många försök. Vänta en stund och försök igen.';
      case 'network-request-failed':
        return 'Nätverksfel. Kontrollera din internetanslutning.';
      default:
        return e.message ?? 'Ett oväntat fel inträffade.';
    }
  }

  /// English copy (e.g. Stitch Login screen).
  String friendlyErrorEnglish(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
