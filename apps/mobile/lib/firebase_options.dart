// File generated for FITFLOW project targeting fitflow-ungvinh
// ignore_for_file: type=lint
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY',
    appId: '1:478201681453:web:548382a87ae04688e48aa4',
    messagingSenderId: '478201681453',
    projectId: 'fitflow-ungvinh',
    authDomain: 'fitflow-ungvinh.firebaseapp.com',
    storageBucket: 'fitflow-ungvinh.firebasestorage.app',
    measurementId: 'G-7P5BQ18ESP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY',
    appId: '1:478201681453:android:548382a87ae04688e48aa4',
    messagingSenderId: '478201681453',
    projectId: 'fitflow-ungvinh',
    storageBucket: 'fitflow-ungvinh.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY',
    appId: '1:478201681453:ios:548382a87ae04688e48aa4',
    messagingSenderId: '478201681453',
    projectId: 'fitflow-ungvinh',
    storageBucket: 'fitflow-ungvinh.firebasestorage.app',
    iosBundleId: 'com.example.vincecore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY',
    appId: '1:478201681453:ios:548382a87ae04688e48aa4',
    messagingSenderId: '478201681453',
    projectId: 'fitflow-ungvinh',
    storageBucket: 'fitflow-ungvinh.firebasestorage.app',
    iosBundleId: 'com.example.vincecore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY',
    appId: '1:478201681453:web:548382a87ae04688e48aa4',
    messagingSenderId: '478201681453',
    projectId: 'fitflow-ungvinh',
    authDomain: 'fitflow-ungvinh.firebaseapp.com',
    storageBucket: 'fitflow-ungvinh.firebasestorage.app',
    measurementId: 'G-7P5BQ18ESP',
  );
}
