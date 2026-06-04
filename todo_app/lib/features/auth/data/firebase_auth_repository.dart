import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';
import 'auth_repository.dart';
import 'auth_session.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthSession?> get sessionChanges {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AuthSession? get currentSession => _mapUser(_auth.currentUser);

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseReady();
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _ensureFirebaseReady();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Account could not be created.',
      );
    }

    final displayName = fullName.trim();

    try {
      await user.updateDisplayName(displayName);
      await user.reload();
    } catch (error, stackTrace) {
      debugPrint('updateDisplayName failed: $error\n$stackTrace');
    }

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'displayName': displayName,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Firestore profile write failed (${error.code}): ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthSession? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthSession(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email ?? 'User',
      isLocalAccount: false,
    );
  }

  Future<void> _ensureFirebaseReady() async {
    if (Firebase.apps.isEmpty) {
      final options = kIsWeb
          ? DefaultFirebaseOptions.web
          : DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);
    }
  }
}
