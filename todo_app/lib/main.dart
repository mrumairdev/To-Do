import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/firebase_bootstrap.dart';
import 'features/auth/data/composite_auth_repository.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/tasks/data/hive_task_repository.dart';
import 'features/tasks/data/task_item.dart';
import 'features/tasks/presentation/task_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseEnabled = await const FirebaseBootstrap().initialize();
  if (kDebugMode) {
    debugPrint('Firebase initialized: $firebaseEnabled');
  }

  final prefs = await SharedPreferences.getInstance();
  final themeProvider = ThemeProvider(prefs);

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(TaskItem.typeId)) {
    Hive.registerAdapter(TaskItemAdapter());
  }

  final tasksBox = await Hive.openBox<TaskItem>('tasks');
  final taskController = TaskController(HiveTaskRepository(tasksBox));

  final localAuth = LocalAuthRepository(prefs);
  final authRepository = firebaseEnabled
      ? CompositeAuthRepository(
          firebase: FirebaseAuthRepository(),
          local: localAuth,
        )
      : localAuth;
  final authController = AuthController(authRepository);

  runApp(
    TodoApp(
      themeProvider: themeProvider,
      taskController: taskController,
      authController: authController,
    ),
  );
}
