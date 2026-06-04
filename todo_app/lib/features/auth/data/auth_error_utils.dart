import 'package:firebase_auth/firebase_auth.dart';

bool isFirebaseConfigurationError(FirebaseAuthException error) {
  if (error.code == 'configuration-not-found' ||
      error.code == 'operation-not-allowed') {
    return true;
  }

  if (error.code == 'internal-error') {
    final message = error.message?.toUpperCase() ?? '';
    return message.contains('CONFIGURATION_NOT_FOUND');
  }

  final message = error.message?.toUpperCase() ?? '';
  return message.contains('CONFIGURATION_NOT_FOUND');
}
