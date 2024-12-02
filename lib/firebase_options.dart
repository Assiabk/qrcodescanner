// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyArpfsuYJvHWrDCXlLZ8iLsj9G6dcbysVM',
    appId: '1:730536506399:web:ea2155ebc605b0707dd12a',
    messagingSenderId: '730536506399',
    projectId: 'qrapp-9c1fc',
    authDomain: 'qrapp-9c1fc.firebaseapp.com',
    storageBucket: 'qrapp-9c1fc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhgq5tadFd5WG40MZ4xb35IaemQd6nvBQ',
    appId: '1:730536506399:android:4d9c605ad63e129f7dd12a',
    messagingSenderId: '730536506399',
    projectId: 'qrapp-9c1fc',
    storageBucket: 'qrapp-9c1fc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCosxxY3_UeuBljwH6ptWoErvBoOAH9Tkw',
    appId: '1:730536506399:ios:abe32bc1f28bbf917dd12a',
    messagingSenderId: '730536506399',
    projectId: 'qrapp-9c1fc',
    storageBucket: 'qrapp-9c1fc.firebasestorage.app',
    iosBundleId: 'com.example.qrApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCosxxY3_UeuBljwH6ptWoErvBoOAH9Tkw',
    appId: '1:730536506399:ios:abe32bc1f28bbf917dd12a',
    messagingSenderId: '730536506399',
    projectId: 'qrapp-9c1fc',
    storageBucket: 'qrapp-9c1fc.firebasestorage.app',
    iosBundleId: 'com.example.qrApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyArpfsuYJvHWrDCXlLZ8iLsj9G6dcbysVM',
    appId: '1:730536506399:web:d3f89e472ff6c8d97dd12a',
    messagingSenderId: '730536506399',
    projectId: 'qrapp-9c1fc',
    authDomain: 'qrapp-9c1fc.firebaseapp.com',
    storageBucket: 'qrapp-9c1fc.firebasestorage.app',
  );
}