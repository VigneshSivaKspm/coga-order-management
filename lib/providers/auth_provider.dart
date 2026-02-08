import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Provider class for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  bool _isAdmin = false;
  StreamSubscription<User?>? _authSubscription;

  /// Current authenticated user
  User? get user => _user;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Remember me state
  bool get rememberMe => _rememberMe;

  /// Check if user is authenticated
  bool get isAuthenticated => _user != null;

  /// Check if user is admin
  bool get isAdmin => _isAdmin;

  /// Get current user ID
  String? get userId => _user?.uid;

  /// Get current user email
  String? get userEmail => _user?.email;

  /// Get current user display name
  String? get displayName => _user?.displayName;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state listener
  void _init() {
    _user = _authService.currentUser;
    if (_user != null) {
      _checkAdminStatus();
    }
    _authSubscription = _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await _checkAdminStatus();
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  /// Check if current user is admin
  Future<void> _checkAdminStatus() async {
    if (_user != null) {
      _isAdmin = await _authService.isUserAdmin(_user!.uid);
      notifyListeners();
    }
  }

  /// Check admin status and return result
  Future<bool> checkIsAdmin() async {
    if (_user != null) {
      _isAdmin = await _authService.isUserAdmin(_user!.uid);
      notifyListeners();
      return _isAdmin;
    }
    return false;
  }

  /// Set remember me preference
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check admin status after sign in
      await _checkAdminStatus();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({required String email, required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up as admin
  Future<bool> signUpAsAdmin({
    required String email,
    required String password,
    required String displayName,
    required String adminCode,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signUpAsAdmin(
        email: email,
        password: password,
        displayName: displayName,
        adminCode: adminCode,
      );

      _isAdmin = true;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signOut();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.sendPasswordResetEmail(email);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.updatePassword(newPassword);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.deleteAccount();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reauthenticate user
  Future<bool> reauthenticate(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.reauthenticate(email, password);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    await _authService.reloadUser();
    _user = _authService.currentUser;
    notifyListeners();
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;
    return await _authService.getUserData(_user!.uid);
  }

  /// Update user data in Firestore
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (_user == null) return false;
    try {
      await _authService.updateUserData(_user!.uid, data);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
