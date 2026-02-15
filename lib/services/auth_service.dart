import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:admission_management/core/constants/app_constants.dart';
import 'package:admission_management/models/user_model.dart';

/// Handles Firebase Authentication and role lookup from Firestore.
/// Students register with email/password; admins login with predefined accounts (stored in Firestore).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register student with email & password and create user document with role: student.
  Future<UserModel?> registerStudent({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return null;

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      role: AppConstants.roleStudent,
    );
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(userModel.toMap());
    return userModel;
  }

  /// Login with email & password. Role is fetched from Firestore (student or admin).
  Future<UserModel?> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getUserFromFirestore(_auth.currentUser?.uid);
  }

  /// Get user document from Firestore (contains role). Used for role-based access.
  Future<UserModel?> getUserFromFirestore(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Sign out from Firebase Auth.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update user display name in Firestore.
  Future<void> updateUserName(String uid, String name) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      AppConstants.name: name,
    });
  }
}
