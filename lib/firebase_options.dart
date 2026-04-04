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
    apiKey: 'AIzaSyAxaLQ3Jj2VimuE-2bUH38cMJ2uwq0m2UU',
    appId: '1:415339822502:web:280f8626613d3034f0a367',
    messagingSenderId: '415339822502',
    projectId: 'jeduai-4b028',
    authDomain: 'jeduai-4b028.firebaseapp.com',
    storageBucket: 'jeduai-4b028.firebasestorage.app',
    measurementId: 'G-GRED4S15ZV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOl0t6ul03RfKcsHHVTLPnew0hsW-vJ9s',
    appId: '1:415339822502:android:e757a2c7ba7df529f0a367',
    messagingSenderId: '415339822502',
    projectId: 'jeduai-4b028',
    storageBucket: 'jeduai-4b028.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOl0t6ul03RfKcsHHVTLPnew0hsW-vJ9s',
    appId: '1:415339822502:ios:e757a2c7ba7df529f0a367',
    messagingSenderId: '415339822502',
    projectId: 'jeduai-4b028',
    storageBucket: 'jeduai-4b028.firebasestorage.app',
    iosBundleId: 'JeduAi.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOl0t6ul03RfKcsHHVTLPnew0hsW-vJ9s',
    appId: '1:415339822502:ios:e757a2c7ba7df529f0a367',
    messagingSenderId: '415339822502',
    projectId: 'jeduai-4b028',
    storageBucket: 'jeduai-4b028.firebasestorage.app',
    iosBundleId: 'JeduAi.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAOl0t6ul03RfKcsHHVTLPnew0hsW-vJ9s',
    appId: '1:415339822502:web:280f8626613d3034f0a367',
    messagingSenderId: '415339822502',
    projectId: 'jeduai-4b028',
    storageBucket: 'jeduai-4b028.firebasestorage.app',
  );
}