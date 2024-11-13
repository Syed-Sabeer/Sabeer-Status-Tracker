
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBO3-gvUvYz-iEqWJ399ENG7FNnflAsJFg',
    appId: '1:651853178036:web:8fa42015c4f0358626a3e1',
    messagingSenderId: '651853178036',
    projectId: 'sabeerstatustracker',
    authDomain: 'sabeerstatustracker.firebaseapp.com',
    storageBucket: 'sabeerstatustracker.firebasestorage.app',
    measurementId: 'G-7G9S3ZCV5X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5PJs66o37qY_r_niYdxsItjS2QVl_yZ8',
    appId: '1:651853178036:android:97bfafcfc22b57ec26a3e1',
    messagingSenderId: '651853178036',
    projectId: 'sabeerstatustracker',
    storageBucket: 'sabeerstatustracker.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBep4e2y6WqKorjb6liBunOpKxqcMmJhZI',
    appId: '1:651853178036:ios:9715096f0b3a0d7f26a3e1',
    messagingSenderId: '651853178036',
    projectId: 'sabeerstatustracker',
    storageBucket: 'sabeerstatustracker.firebasestorage.app',
    iosBundleId: 'com.example.sabeerstatus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBep4e2y6WqKorjb6liBunOpKxqcMmJhZI',
    appId: '1:651853178036:ios:9715096f0b3a0d7f26a3e1',
    messagingSenderId: '651853178036',
    projectId: 'sabeerstatustracker',
    storageBucket: 'sabeerstatustracker.firebasestorage.app',
    iosBundleId: 'com.example.sabeerstatus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBO3-gvUvYz-iEqWJ399ENG7FNnflAsJFg',
    appId: '1:651853178036:web:0facc5ccfbdb389026a3e1',
    messagingSenderId: '651853178036',
    projectId: 'sabeerstatustracker',
    authDomain: 'sabeerstatustracker.firebaseapp.com',
    storageBucket: 'sabeerstatustracker.firebasestorage.app',
    measurementId: 'G-3FTL59KWYD',
  );
}
