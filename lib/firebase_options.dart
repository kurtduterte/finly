import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      _ensureConfig(
        platform: 'web',
        values: {
          'FIREBASE_WEB_API_KEY': web.apiKey,
          'FIREBASE_WEB_APP_ID': web.appId,
          'FIREBASE_MESSAGING_SENDER_ID': web.messagingSenderId,
          'FIREBASE_PROJECT_ID': web.projectId,
          'FIREBASE_AUTH_DOMAIN': web.authDomain ?? '',
          'FIREBASE_STORAGE_BUCKET': web.storageBucket ?? '',
        },
      );
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      _ensureConfig(
        platform: 'android',
        values: {
          'FIREBASE_ANDROID_API_KEY': android.apiKey,
          'FIREBASE_ANDROID_APP_ID': android.appId,
          'FIREBASE_MESSAGING_SENDER_ID': android.messagingSenderId,
          'FIREBASE_PROJECT_ID': android.projectId,
          'FIREBASE_STORAGE_BUCKET': android.storageBucket ?? '',
        },
      );
      return android;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _ensureConfig(
        platform: 'ios',
        values: {
          'FIREBASE_IOS_API_KEY': ios.apiKey,
          'FIREBASE_IOS_APP_ID': ios.appId,
          'FIREBASE_MESSAGING_SENDER_ID': ios.messagingSenderId,
          'FIREBASE_PROJECT_ID': ios.projectId,
          'FIREBASE_STORAGE_BUCKET': ios.storageBucket ?? '',
          'FIREBASE_IOS_BUNDLE_ID': ios.iosBundleId ?? '',
        },
      );
      return ios;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      _ensureConfig(
        platform: 'macos',
        values: {
          'FIREBASE_IOS_API_KEY': macos.apiKey,
          'FIREBASE_IOS_APP_ID': macos.appId,
          'FIREBASE_MESSAGING_SENDER_ID': macos.messagingSenderId,
          'FIREBASE_PROJECT_ID': macos.projectId,
          'FIREBASE_STORAGE_BUCKET': macos.storageBucket ?? '',
          'FIREBASE_IOS_BUNDLE_ID': macos.iosBundleId ?? '',
        },
      );
      return macos;
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      _ensureConfig(
        platform: 'windows',
        values: {
          'FIREBASE_WEB_API_KEY': windows.apiKey,
          'FIREBASE_WINDOWS_APP_ID': windows.appId,
          'FIREBASE_MESSAGING_SENDER_ID': windows.messagingSenderId,
          'FIREBASE_PROJECT_ID': windows.projectId,
          'FIREBASE_AUTH_DOMAIN': windows.authDomain ?? '',
          'FIREBASE_STORAGE_BUCKET': windows.storageBucket ?? '',
        },
      );
      return windows;
    }

    if (defaultTargetPlatform == TargetPlatform.linux) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for linux - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static void _ensureConfig({
    required String platform,
    required Map<String, String> values,
  }) {
    final missingKeys = <String>[
      for (final entry in values.entries)
        if (entry.value.trim().isEmpty) entry.key,
    ];
    if (missingKeys.isNotEmpty) {
      throw UnsupportedError(
        'Missing Firebase config for $platform: ${missingKeys.join(', ')}. '
        'Set them in .env.json and run with --dart-define-from-file=.env.json.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('FIREBASE_WINDOWS_MEASUREMENT_ID'),
  );
}
