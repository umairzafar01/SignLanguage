import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthState { unauthenticated, guest, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required bool firebaseEnabled,
    // googleWebClientId kept in signature so main.dart doesn't break,
    // but Google Sign-In is removed.
    String? googleWebClientId,
  }) : _firebaseEnabled = firebaseEnabled {
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
  String _photoUrl = '';

  AuthState get state => _state;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get photoUrl => _photoUrl;
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
      await _auth!.signInWithEmailAndPassword(
          email: email, password: password);
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
      final credential = await _auth!
          .createUserWithEmailAndPassword(email: email, password: password);
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
    } else {
      _state = AuthState.unauthenticated;
      _userName = '';
      _userEmail = '';
      _photoUrl = '';
      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      if (_state != AuthState.guest) {
        _state = AuthState.unauthenticated;
        _userName = '';
        _userEmail = '';
        _photoUrl = '';
      }
      notifyListeners();
      return;
    }
    _state = AuthState.authenticated;
    _userName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : (user.email?.split('@').first.replaceAll('.', ' ') ?? 'User');
    _userEmail = user.email ?? '';
    _photoUrl = user.photoURL ?? '';
    _syncUserProfile();
    notifyListeners();
  }

  void _ensureFirebaseClients() {
    if (!_firebaseEnabled) return;
    _auth ??= FirebaseAuth.instance;
  }

  Future<bool> updateProfile(
      {required String name, required String email}) async {
    _lastError = null;
    _ensureFirebaseClients();
    if (!_firebaseEnabled || _auth?.currentUser == null) {
      _lastError = 'Please sign in first.';
      notifyListeners();
      return false;
    }
    try {
      final user = _auth!.currentUser!;
      if (name.trim().isNotEmpty &&
          name.trim() != (user.displayName ?? '')) {
        await user.updateDisplayName(name.trim());
      }
      if (email.trim().isNotEmpty && email.trim() != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }
      await user.reload();
      _onAuthStateChanged(_auth!.currentUser);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to update profile.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _lastError = null;
    _ensureFirebaseClients();
    if (!_firebaseEnabled || _auth?.currentUser == null) {
      _lastError = 'Please sign in first.';
      notifyListeners();
      return false;
    }
    try {
      final user = _auth!.currentUser!;
      final email = user.email;
      if (email == null || email.isEmpty) {
        _lastError = 'Password change is not available for this account.';
        notifyListeners();
        return false;
      }
      final credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to change password.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset() async {
    _lastError = null;
    _ensureFirebaseClients();
    final email = _auth?.currentUser?.email ?? _userEmail;
    if (!_firebaseEnabled || email.isEmpty) {
      _lastError = 'No email found for password reset.';
      notifyListeners();
      return false;
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to send reset email.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePhotoUrl(String photoUrl) async {
    _lastError = null;
    _ensureFirebaseClients();
    if (!_firebaseEnabled || _auth?.currentUser == null) {
      _lastError = 'Please sign in first.';
      notifyListeners();
      return false;
    }
    try {
      await _auth!.currentUser!.updatePhotoURL(photoUrl);
      _photoUrl = photoUrl;
      await _syncUserProfile();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? 'Unable to update photo.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncUserProfile() async {
    if (!_firebaseEnabled || _auth?.currentUser == null) return;
    final user = _auth!.currentUser!;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // best-effort sync
    }
  }
}
