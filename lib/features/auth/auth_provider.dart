import 'package:flutter/material.dart';

enum AuthState { unauthenticated, guest, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unauthenticated;
  String _userName = '';
  String _userEmail = '';

  AuthState get state => _state;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isGuest => _state == AuthState.guest;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email.isNotEmpty && password.length >= 6) {
      _state = AuthState.authenticated;
      _userName = email.split('@').first.replaceAll('.', ' ');
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 8) {
      _state = AuthState.authenticated;
      _userName = name;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void continueAsGuest() {
    _state = AuthState.guest;
    _userName = 'Guest';
    _userEmail = '';
    notifyListeners();
  }

  void signOut() {
    _state = AuthState.unauthenticated;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}
