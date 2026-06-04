import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth_error_utils.dart';
import 'auth_repository.dart';
import 'auth_session.dart';
import 'firebase_auth_repository.dart';
import 'local_auth_repository.dart';

/// Tries Firebase Auth first; falls back to on-device accounts when Firebase
/// Authentication is not enabled in the Firebase Console yet.
class CompositeAuthRepository implements AuthRepository {
  CompositeAuthRepository({
    required FirebaseAuthRepository firebase,
    required LocalAuthRepository local,
  }) : _firebase = firebase,
       _local = local {
    // Prefer Firebase Auth if available. Only switch to the local
    // fallback when a Firebase operation fails with a configuration
    // error (handled in signIn/signUp).
    _active = _firebase;
  }

  final FirebaseAuthRepository _firebase;
  final LocalAuthRepository _local;

  late AuthRepository _active;
  bool _usingLocalFallback = false;

  bool get usingLocalFallback => _usingLocalFallback;

  @override
  Stream<AuthSession?> get sessionChanges => _active.sessionChanges;

  @override
  AuthSession? get currentSession => _active.currentSession;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (_usingLocalFallback) {
      await _local.signIn(email: email, password: password);
      return;
    }

    try {
      await _firebase.signIn(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      if (!isFirebaseConfigurationError(error)) {
        rethrow;
      }
      await _activateLocalFallback();
      await _local.signIn(email: email, password: password);
    }
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (_usingLocalFallback) {
      await _local.signUp(fullName: fullName, email: email, password: password);
      return;
    }

    try {
      await _firebase.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (!isFirebaseConfigurationError(error)) {
        rethrow;
      }
      debugPrint(
        'Firebase Auth not enabled — enable Email/Password in Firebase Console (Authentication → Sign-in method). Falling back to on-device accounts for now.',
      );
      await _activateLocalFallback();
      await _local.signUp(fullName: fullName, email: email, password: password);
    }
  }

  @override
  Future<void> signOut() => _active.signOut();

  Future<void> _activateLocalFallback() async {
    _usingLocalFallback = true;
    _active = _local;
  }
}
