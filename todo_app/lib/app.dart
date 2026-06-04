import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/tasks/presentation/task_controller.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({
    super.key,
    required this.themeProvider,
    required this.taskController,
    required this.authController,
  });

  final ThemeProvider themeProvider;
  final TaskController taskController;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<TaskController>.value(value: taskController),
        ChangeNotifierProvider<AuthController>.value(value: authController),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Todo App',
            theme: theme.themeData,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
