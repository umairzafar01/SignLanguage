import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthState { unauthenticated, guest, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required bool firebaseEnabled}) : _firebaseEnabled = firebaseEnabled {
    if (_firebaseEnabled) {
      _ensureFirebaseClients();
      _auth?.authStateChanges().listen(_onAuthStateChanged);
    }
  }

  AuthState _state = AuthState.unauthenticated;
  String _userName = '';
  String _userEmail = '';
  final bool _firebaseEnabled;
  String? _lastError;
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  AuthState get state => _state;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get lastError => _lastError;
  bool get isGuest => _state == AuthState.guest;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String? get userId => _auth?.currentUser?.uid;
  bool get firebaseEnabled => _firebaseEnabled;

  Future<bool> signIn(String email, String password) async {
    _lastError = null;
    if (!_firebaseEnabled) {
      _lastError = 'Firebase is not configured. Add Firebase options first.';
      notifyListeners();
      return false;
    }
    _ensureFirebaseClients();
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to sign in right now.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _lastError = null;
    if (!_firebaseEnabled) {
      _lastError = 'Firebase is not configured. Add Firebase options first.';
      notifyListeners();
      return false;
    }
    _ensureFirebaseClients();
    try {
      final credential =
          await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      if (name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to create account right now.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _lastError = null;
    if (!_firebaseEnabled) {
      _lastError = 'Firebase is not configured. Add Firebase options first.';
      notifyListeners();
      return false;
    }
    _ensureFirebaseClients();
    try {
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth!.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Google sign-in failed.';
      notifyListeners();
      return false;
    } catch (_) {
      _lastError = 'Google sign-in failed.';
      notifyListeners();
      return false;
    }
  }

  void continueAsGuest() {
    _lastError = null;
    _state = AuthState.guest;
    _userName = 'Guest';
    _userEmail = '';
    notifyListeners();
  }

  void signOut() {
    _lastError = null;
    _ensureFirebaseClients();
    if (_firebaseEnabled && _auth?.currentUser != null) {
      _auth!.signOut();
      _googleSignIn?.signOut();
    } else {
      _state = AuthState.unauthenticated;
      _userName = '';
      _userEmail = '';
      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      if (_state != AuthState.guest) {
        _state = AuthState.unauthenticated;
        _userName = '';
        _userEmail = '';
      }
      notifyListeners();
      return;
    }
    _state = AuthState.authenticated;
    _userName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : (user.email?.split('@').first.replaceAll('.', ' ') ?? 'User');
    _userEmail = user.email ?? '';
    notifyListeners();
  }

  void _ensureFirebaseClients() {
    if (!_firebaseEnabled) return;
    _auth ??= FirebaseAuth.instance;
    _googleSignIn ??= GoogleSignIn();
  }
}
