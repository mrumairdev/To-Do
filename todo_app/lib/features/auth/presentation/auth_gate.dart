import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tasks/presentation/task_home_screen.dart';
import '../data/auth_session.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return StreamBuilder<AuthSession?>(
      stream: auth.sessionChanges,
      initialData: auth.currentSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const TaskHomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
