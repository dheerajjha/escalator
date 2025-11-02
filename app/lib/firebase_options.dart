// File generated manually from Firebase config files
// Do not modify by hand

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDf33etYo8krGfOEcYn1ELmzs7X1sJ8Amc',
    appId: '1:21377449151:web:XXXXXX',
    messagingSenderId: '21377449151',
    projectId: 'escalator-af43a',
    authDomain: 'escalator-af43a.firebaseapp.com',
    storageBucket: 'escalator-af43a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBg3yAFdwALuXyOCXv_RhvDNiyoqpym3uc',
    appId: '1:21377449151:android:8006d7f7926bffc36d9a0a',
    messagingSenderId: '21377449151',
    projectId: 'escalator-af43a',
    storageBucket: 'escalator-af43a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDf33etYo8krGfOEcYn1ELmzs7X1sJ8Amc',
    appId: '1:21377449151:ios:b523e24146c1bd646d9a0a',
    messagingSenderId: '21377449151',
    projectId: 'escalator-af43a',
    storageBucket: 'escalator-af43a.firebasestorage.app',
    iosBundleId: 'com.example.escalator',
  );
}
