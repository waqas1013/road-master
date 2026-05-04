import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFyc0CKb83ouLPTFLKA5bcmoWVgJlQrDw',
    appId: '1:685054591368:android:512ff59755b5fa4bc5ba3d',
    messagingSenderId: '685054591368',
    projectId: 'road-master-se',
    storageBucket: 'road-master-se.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBR5QMDUFdvtHmvBFO4aznKd1PySWoubCc',
    appId: '1:685054591368:ios:541acc7fc008cffcc5ba3d',
    messagingSenderId: '685054591368',
    projectId: 'road-master-se',
    storageBucket: 'road-master-se.firebasestorage.app',
    iosBundleId: 'com.roadmaster.roadMaster',
  );
}
