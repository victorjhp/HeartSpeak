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
    apiKey: 'AIzaSyBqp9ZgrxKZpu8gx2SaxdT3nvx0zpc_vSs',
    appId: '1:419793111903:web:ee968d013012545deb04ea',
    messagingSenderId: '419793111903',
    projectId: 'paac-72b16',
    authDomain: 'paac-72b16.firebaseapp.com',
    storageBucket: 'paac-72b16.appspot.com',
    measurementId: 'G-CFF5SETCWS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPCcaLHOZfiMj-yngS1cdaU78zvfAPSEI',
    appId: '1:419793111903:android:751e6f217bfb969eeb04ea',
    messagingSenderId: '419793111903',
    projectId: 'paac-72b16',
    storageBucket: 'paac-72b16.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqoWqpW6pSCvO62IK9yhvKHzj2zDoVBPA',
    appId: '1:419793111903:ios:c230cdb644b4b170eb04ea',
    messagingSenderId: '419793111903',
    projectId: 'paac-72b16',
    storageBucket: 'paac-72b16.appspot.com',
    iosBundleId: 'com.example.firstly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqoWqpW6pSCvO62IK9yhvKHzj2zDoVBPA',
    appId: '1:419793111903:ios:c230cdb644b4b170eb04ea',
    messagingSenderId: '419793111903',
    projectId: 'paac-72b16',
    storageBucket: 'paac-72b16.appspot.com',
    iosBundleId: 'com.example.firstly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqp9ZgrxKZpu8gx2SaxdT3nvx0zpc_vSs',
    appId: '1:419793111903:web:5e876df5467250e9eb04ea',
    messagingSenderId: '419793111903',
    projectId: 'paac-72b16',
    authDomain: 'paac-72b16.firebaseapp.com',
    storageBucket: 'paac-72b16.appspot.com',
    measurementId: 'G-154B6JTDK3',
  );
}
