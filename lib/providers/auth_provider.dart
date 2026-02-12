import 'package:flutter/foundation.dart';

import 'package:admission_management/models/user_model.dart';
import 'package:admission_management/services/auth_service.dart';

/// Auth state: current user (with role) and loading. Used for role-based navigation.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        final userModel = await _authService.getUserFromFirestore(firebaseUser.uid);
        // Don't overwrite with null during registration - doc may not exist yet
        if (userModel != null || !_isLoading) {
          _user = userModel;
        }
      } else if (!_isLoading) {
        _user = null;
      }
      notifyListeners();
    });
  }

  /// Register student (email & password) and create user doc with role: student.
  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final u = await _authService.registerStudent(
        name: name,
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw Exception('Registration timed out. Check your internet connection.'),
      );
      _user = u;
      _isLoading = false;
      notifyListeners();
      return u != null;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login (student or admin). Role comes from Firestore.
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final u = await _authService
          .login(email: email, password: password)
          .timeout(
            const Duration(seconds: 25),
            onTimeout: () => throw Exception('Login timed out. Check your internet connection.'),
          );
      _user = u;
      _isLoading = false;
      notifyListeners();
      return u != null;
    } catch (e) {
      _error = _formatAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatAuthError(Object e) {
    final msg = e.toString();
    // Extract user-friendly message from Firebase errors
    final bracketMatch = RegExp(r'\[([^\]]+)\]\s*(.*)').firstMatch(msg);
    if (bracketMatch != null) {
      final code = bracketMatch.group(1) ?? '';
      final detail = bracketMatch.group(2)?.trim() ?? '';
      if (code.contains('permission-denied')) {
        return 'Permission denied. Ensure Firestore rules allow user creation.';
      }
      if (code.contains('email-already-in-use')) return 'This email is already registered. Try logging in.';
      if (code.contains('invalid-email')) return 'Please enter a valid email address.';
      if (code.contains('weak-password')) return 'Password should be at least 6 characters.';
      if (code.contains('user-not-found')) return 'No account found. Please register first.';
      if (code.contains('wrong-password')) return 'Incorrect password.';
      if (detail.isNotEmpty) return detail;
    }
    return msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
  }

  /// Refresh user from Firestore (e.g. after app resume).
  Future<void> refreshUser() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _user = await _authService.getUserFromFirestore(uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
