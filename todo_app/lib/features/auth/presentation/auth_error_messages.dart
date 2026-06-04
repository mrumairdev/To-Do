import 'package:firebase_auth/firebase_auth.dart';

/// Turns Firebase / unknown errors into clear user-facing text.
class AuthErrorMessages {
  static const String authNotEnabled = 'Firebase Authentication is not enabled '
      'for this project yet. Open Firebase Console → Authentication → '
      'Get started → Sign-in method → turn on Email/Password. '
      'Then under Authentication → Settings → Authorized domains, add '
      'localhost and 127.0.0.1. Restart the app and try again.';

  static String fromObject(Object error) {
    if (error is FirebaseAuthException) {
      return fromAuthException(error);
    }

    final text = error.toString().toLowerCase();
    if (text.contains('configuration_not_found') ||
        text.contains('configuration-not-found')) {
      return authNotEnabled;
    }

    for (final code in _knownCodes) {
      if (text.contains(code)) {
        return forCode(code);
      }
    }

    return 'Could not complete this action. Check your connection and Firebase setup.';
  }

  static String fromAuthException(FirebaseAuthException error) {
    if (_isConfigurationNotFound(error)) {
      return authNotEnabled;
    }

    final byCode = forCode(error.code);
    if (byCode != _genericForUnknownCode(error.code)) {
      return byCode;
    }
    if (!_isUselessMessage(error.message)) {
      return error.message!.trim();
    }
    return byCode;
  }

  static bool isConfigurationError(FirebaseAuthException error) {
    return _isConfigurationNotFound(error);
  }

  static bool _isConfigurationNotFound(FirebaseAuthException error) {
    if (error.code == 'configuration-not-found') {
      return true;
    }
    final message = error.message?.toUpperCase() ?? '';
    return message.contains('CONFIGURATION_NOT_FOUND');
  }

  static String forCode(String code) {
    return switch (code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found for that email.',
      'wrong-password' => 'Incorrect password. Try again.',
      'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' =>
        'That email is already registered. Use Log in instead.',
      'weak-password' =>
        'Password is too weak. Use at least 8 characters with upper, lower, and a number.',
      'operation-not-allowed' => authNotEnabled,
      'network-request-failed' =>
        'Network error. Check your internet connection and try again.',
      'too-many-requests' =>
        'Too many attempts. Wait a few minutes and try again.',
      'internal-error' => authNotEnabled,
      'configuration-not-found' => authNotEnabled,
      'invalid-api-key' =>
        'Invalid Firebase API key. Run flutterfire configure again in todo_app.',
      'app-not-authorized' =>
        'This app is not authorized for Firebase. Check API key and authorized domains.',
      'user-not-created' => 'Account could not be created. Please try again.',
      'permission-denied' =>
        'Could not save your profile in Firestore. Publish firestore.rules in Firebase Console.',
      'unavailable' => 'Firestore is unavailable. Try again in a moment.',
      _ => _genericForUnknownCode(code),
    };
  }

  static String _genericForUnknownCode(String code) {
    if (code.isEmpty) {
      return 'Authentication failed. Check Firebase Console settings.';
    }
    return 'Authentication failed ($code). Check Firebase Console settings.';
  }

  static bool _isUselessMessage(String? message) {
    if (message == null) {
      return true;
    }
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return true;
    }
    final lower = trimmed.toLowerCase();
    return lower == 'error' ||
        lower == 'internal error' ||
        lower == 'an internal error has occurred.' ||
        lower == 'internal-error';
  }

  static const List<String> _knownCodes = [
    'invalid-email',
    'user-disabled',
    'user-not-found',
    'wrong-password',
    'invalid-credential',
    'email-already-in-use',
    'weak-password',
    'operation-not-allowed',
    'network-request-failed',
    'too-many-requests',
    'internal-error',
    'configuration-not-found',
    'permission-denied',
  ];
}
