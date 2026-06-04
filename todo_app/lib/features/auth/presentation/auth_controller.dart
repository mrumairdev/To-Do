import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_failure.dart';
import '../data/auth_repository.dart';
import '../data/auth_session.dart';
import 'auth_error_messages.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? infoMessage;

  Stream<AuthSession?> get sessionChanges => _repository.sessionChanges;

  AuthSession? get currentSession => _repository.currentSession;

  void clearError() {
    if (errorMessage == null && infoMessage == null) {
      return;
    }
    errorMessage = null;
    infoMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() {
      return _repository.signIn(email: email, password: password);
    });
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() {
      return _repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    });
  }

  Future<void> signOut() => _repository.signOut();

  String? get _localFallbackSuccessMessage {
    final session = currentSession;
    if (session?.isLocalAccount == true) {
      return 'Account saved on this device. Enable Firebase Email/Password to sync across devices.';
    }
    return null;
  }

  Future<bool> _runAuthAction(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    isLoading = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();

    try {
      await action();
      infoMessage = successMessage ?? _localFallbackSuccessMessage;
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = AuthErrorMessages.fromAuthException(error);
      debugPrint('FirebaseAuthException: code=${error.code} message=${error.message}');
      return false;
    } on AuthFailure catch (error) {
      errorMessage = AuthErrorMessages.forCode(error.code);
      return false;
    } catch (error, stackTrace) {
      errorMessage = AuthErrorMessages.fromObject(error);
      debugPrint('Auth error: $error\n$stackTrace');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
