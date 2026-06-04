class AuthSession {
  const AuthSession({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isLocalAccount = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final bool isLocalAccount;
}
