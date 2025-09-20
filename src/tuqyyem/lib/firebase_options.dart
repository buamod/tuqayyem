import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Replace these placeholder values with actual values from your Firebase config files
    return const FirebaseOptions(
      apiKey: 'your-api-key',
      appId: 'your-app-id',
      messagingSenderId: 'your-sender-id',
      projectId: 'your-project-id',
      authDomain: 'your-auth-domain',
      storageBucket: 'your-storage-bucket',
    );
  }
}
