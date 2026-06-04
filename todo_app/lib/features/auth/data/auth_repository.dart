import 'auth_session.dart';

abstract class AuthRepository {
  Stream<AuthSession?> get sessionChanges;

  AuthSession? get currentSession;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
