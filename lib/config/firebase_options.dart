// Firebase configuration file
// Replace these values with your actual Firebase project configuration
// You can find these values in your Firebase Console:
// Project Settings > General > Your apps > Firebase SDK snippet

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

  // Firebase Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0EauSBfzLcvzuwPlel55wXQSVfj89P3Y',
    appId: '1:521411021199:web:d436758790f48c0004e3fa',
    messagingSenderId: '521411021199',
    projectId: 'coga-670f5',
    authDomain: 'coga-670f5.firebaseapp.com',
    storageBucket: 'coga-670f5.firebasestorage.app',
    measurementId: 'G-7TT62HXKQP',
  );

  // Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0EauSBfzLcvzuwPlel55wXQSVfj89P3Y',
    appId: '1:521411021199:web:d436758790f48c0004e3fa',
    messagingSenderId: '521411021199',
    projectId: 'coga-670f5',
    storageBucket: 'coga-670f5.firebasestorage.app',
  );

  // Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0EauSBfzLcvzuwPlel55wXQSVfj89P3Y',
    appId: '1:521411021199:web:d436758790f48c0004e3fa',
    messagingSenderId: '521411021199',
    projectId: 'coga-670f5',
    storageBucket: 'coga-670f5.firebasestorage.app',
    iosBundleId: 'com.example.coga',
  );

  // Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0EauSBfzLcvzuwPlel55wXQSVfj89P3Y',
    appId: '1:521411021199:web:d436758790f48c0004e3fa',
    messagingSenderId: '521411021199',
    projectId: 'coga-670f5',
    storageBucket: 'coga-670f5.firebasestorage.app',
    iosBundleId: 'com.example.coga',
  );

  // Firebase Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB0EauSBfzLcvzuwPlel55wXQSVfj89P3Y',
    appId: '1:521411021199:web:d436758790f48c0004e3fa',
    messagingSenderId: '521411021199',
    projectId: 'coga-670f5',
    authDomain: 'coga-670f5.firebaseapp.com',
    storageBucket: 'coga-670f5.firebasestorage.app',
  );
}

/*
=============================================================================
HOW TO CONFIGURE FIREBASE:
=============================================================================

1. Go to https://console.firebase.google.com/
2. Create a new project or select an existing one
3. Add your app platforms (Android, iOS, Web)
4. Download the configuration files:
   - Android: google-services.json → place in android/app/
   - iOS: GoogleService-Info.plist → place in ios/Runner/
5. Run the FlutterFire CLI to auto-generate this file:
   
   dart pub global activate flutterfire_cli
   flutterfire configure

   This will automatically update this file with your Firebase configuration.

6. Make sure to enable the following in Firebase Console:
   - Authentication > Email/Password provider
   - Cloud Firestore database (in production mode with proper rules)

=============================================================================
FIRESTORE SECURITY RULES (Example):
=============================================================================

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Orders collection
    match /orders/{orderId} {
      // Allow admin to read all orders
      allow read: if request.auth != null;
      
      // Allow users to read their own orders
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      
      // Allow admin to update order status
      allow update: if request.auth != null && 
        (request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['status', 'paymentStatus', 'updatedAt']));
      
      // Allow authenticated users to create orders
      allow create: if request.auth != null;
    }
  }
}

=============================================================================
*/
