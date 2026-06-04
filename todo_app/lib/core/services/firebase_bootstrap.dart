import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap();

  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        return true;
      }

      final options = kIsWeb
          ? DefaultFirebaseOptions.web
          : DefaultFirebaseOptions.currentPlatform;

      await Firebase.initializeApp(options: options);

      if (kDebugMode) {
        final app = Firebase.app();
        debugPrint(
          'Firebase ready: project=${app.options.projectId} '
          'platform=${kIsWeb ? 'web' : defaultTargetPlatform.name}',
        );
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint('FirebaseBootstrap.initialize failed: $error\n$stackTrace');
      return false;
    }
  }
}
