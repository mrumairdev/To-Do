import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_failure.dart';
import 'auth_repository.dart';
import 'auth_session.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs) {
    _sessionController.add(currentSession);
  }

  static const String _usersKey = 'local_auth_users_json';
  static const String _sessionEmailKey = 'local_auth_session_email';

  final SharedPreferences _prefs;
  final _sessionController = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> get sessionChanges => _sessionController.stream;

  @override
  AuthSession? get currentSession {
    final email = _prefs.getString(_sessionEmailKey);
    if (email == null) {
      return null;
    }
    final users = _readUsers();
    final record = users[email];
    if (record == null) {
      return null;
    }
    return AuthSession(
      uid: record.uid,
      email: email,
      displayName: record.displayName,
      isLocalAccount: true,
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers();
    final record = users[normalizedEmail];
    if (record == null) {
      throw const AuthFailure('user-not-found', 'No account found for that email.');
    }
    if (record.passwordHash != _hashPassword(normalizedEmail, password)) {
      throw const AuthFailure('wrong-password', 'Incorrect password.');
    }
    await _prefs.setString(_sessionEmailKey, normalizedEmail);
    _emitSession();
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _readUsers();
    if (users.containsKey(normalizedEmail)) {
      throw const AuthFailure(
        'email-already-in-use',
        'That email is already registered.',
      );
    }

    users[normalizedEmail] = _StoredUser(
      uid: DateTime.now().microsecondsSinceEpoch.toString(),
      displayName: fullName.trim(),
      passwordHash: _hashPassword(normalizedEmail, password),
    );
    await _writeUsers(users);
    await _prefs.setString(_sessionEmailKey, normalizedEmail);
    _emitSession();
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_sessionEmailKey);
    _emitSession();
  }

  void _emitSession() {
    _sessionController.add(currentSession);
  }

  String _hashPassword(String email, String password) {
    final bytes = utf8.encode('$email::$password');
    return sha256.convert(bytes).toString();
  }

  Map<String, _StoredUser> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        _StoredUser.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> _writeUsers(Map<String, _StoredUser> users) async {
    final encoded = jsonEncode(
      users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs.setString(_usersKey, encoded);
  }
}

class _StoredUser {
  const _StoredUser({
    required this.uid,
    required this.displayName,
    required this.passwordHash,
  });

  factory _StoredUser.fromJson(Map<String, dynamic> json) {
    return _StoredUser(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      passwordHash: json['passwordHash'] as String,
    );
  }

  final String uid;
  final String displayName;
  final String passwordHash;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'passwordHash': passwordHash,
      };
}
