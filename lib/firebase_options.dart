
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Web configuration
    return const FirebaseOptions(
        apiKey: "AIzaSyA8FvKLKpWanhjt9M1rgkec4sffdPgzxuQ",
        authDomain: "myproject1-36207.firebaseapp.com",
        projectId: "myproject1-36207",
        storageBucket: "myproject1-36207.firebasestorage.app",
        messagingSenderId: "418612369644",
        appId: "1:418612369644:web:041ec38ae5a3f2a57b2dc9",
        measurementId: "G-PJKX1N78HQ"
// Initialize Firebase
    );
  }
}
