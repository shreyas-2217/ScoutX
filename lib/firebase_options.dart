import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// PLACEHOLDER options.
///
/// These are empty until you run:
///   flutterfire configure
/// That command logs you into Firebase and regenerates this file with your
/// real project credentials, so both Android and Web will start working.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported on this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwPD9lhjdLFyOb483NnJHYZ3G2pjiSfrU',
    appId: '1:353251846505:android:1a328f65e417aca64ef5f8',
    messagingSenderId: '353251846505',
    projectId: 'scoutx-ed075',
    storageBucket: 'scoutx-ed075.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWqmfIKz9sn77MP4ok0GSIL_GreknoxmY',
    appId: '1:353251846505:web:716bc681127a5c364ef5f8',
    messagingSenderId: '353251846505',
    projectId: 'scoutx-ed075',
    authDomain: 'scoutx-ed075.firebaseapp.com',
    storageBucket: 'scoutx-ed075.firebasestorage.app',
  );
}
