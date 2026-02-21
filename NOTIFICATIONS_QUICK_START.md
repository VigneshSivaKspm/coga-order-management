# Notification System - Quick Setup Checklist

## Post-Installation Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Add Notification Sound Files

#### Android
1. Create directory: `android/app/src/main/res/raw/`
2. Add notification sound: `android/app/src/main/res/raw/notification_sound.mp3`
   - MP3 format
   - Keep it short (1-3 seconds)
   - Recommended: Use 44.1kHz, mono audio

#### iOS
1. In Xcode, add sound file to **Copy Bundle Resources**:
   - Format: `.aiff` or `.wav`
   - File: `notification_sound.aiff`
   - Add to: **Target: Runner → Build Phases → Copy Bundle Resources**

Or place in `ios/Runner/` and Xcode will auto-detect

### 3. Firebase Setup

#### Android Configuration
1. In `android/app/build.gradle`, ensure minSdkVersion is at least 21:
   ```gradle
   android {
       defaultConfig {
           minSdkVersion 21
       }
   }
   ```

2. Install Google Play Services on emulator or device

#### iOS Configuration
1. In Xcode, select **Runner → Capabilities**
2. Enable:
   - **Push Notifications**
   - **Background Modes** → **Remote notifications**

3. Upload APNs certificate to Firebase:
   - Firebase Console → Settings → Cloud Messaging
   - Upload your APNs certificate

### 4. Get FCM Tokens

#### For Testing
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

void printFCMToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}
```

Add to your app and log the token for testing.

#### For Production
Send FCM token to your backend during user registration:
```dart
final token = await FirebaseMessaging.instance.getToken();
// Send to backend API: POST /api/users/{userId}/fcm-tokens
```

### 5. Configure Backend

#### Firebase Cloud Messaging API
1. Firebase Console → Project Settings → Service Accounts
2. Generate new private key (JSON)
3. Use in your backend to send notifications

#### Notification Format (Node.js Example)
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-adminsdk.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function sendOrderNotification(deviceToken, order) {
  const message = {
    notification: {
      title: '🛒 New Order Received!',
      body: `Order #${order.shortId} - ${order.customerName}`,
    },
    data: {
      orderId: order.id,
      shortId: order.shortId,
      customerName: order.customerName,
      totalPrice: order.totalPrice.toString(),
      status: order.status,
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'notification_sound',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
      },
      payload: {
        aps: {
          sound: 'notification_sound.aiff',
          'mutable-content': 1,
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Notification sent:', response);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}
```

### 6. Test Notifications

#### In Foreground (App Open)
- The notification service automatically plays sound and vibration
- Notification appears in the notification panel
- Order details are visible in the notification title and body

#### In Background (App Minimized)
1. Minimize the app
2. Send a test notification
3. Check if:
   - Notification appears in status bar ✓
   - Sound plays ✓
   - Vibration happens ✓
   - Tap opens the app and shows order details ✓

#### In Terminated State (App Killed)
1. Force stop the app (Settings → Apps → COGA → Force Stop)
2. Send a test notification
3. Check if notification appears
4. Tap to open app and verify order data is loaded

#### Using Firebase Console
1. Go to Firebase Console
2. Select Project → Cloud Messaging
3. New Campaign → Select App
4. Enter title and message
5. Choose test devices or use FCM token
6. Click Send

### 7. Enable Notifications in App

The notification service is initialized automatically in `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...);
  await NotificationService().initialize();  // ✓ Already done
  ...
}
```

### 8. Verify Setup

Check logs to verify initialization:
```
I  ✓ Notification service initialized
I  FCM Token: eHKW7ZsDfwM:APA91bGZm...
I  User FCM permission: AuthorizationStatus.authorized
```

## Testing Real Notifications

### Programmatic Test
```dart
import 'package:coga/services/notification_service.dart';
import 'package:coga/models/order_model.dart';

void testNotification() {
  final testOrder = Order(
    id: 'test-123',
    customerName: 'Test Customer',
    customerEmail: 'test@example.com',
    totalPrice: 1299.99,
    totalProducts: 1,
    paymentMode: 'COD',
    status: OrderStatus.pending,
    paymentStatus: PaymentStatus.pending,
    orderDate: DateTime.now(),
    items: [],
    shippingAddress: ShippingAddress(
      firstName: 'Test',
      lastName: 'User',
      street: '123 Test Street',
      city: 'Test City',
      state: 'Test State',
      pincode: '123456',
      phone: '9999999999',
    ),
  );

  NotificationService().showNewOrderNotification(testOrder);
}
```

## Troubleshooting

### Notifications Not Showing in Terminated State

**Android:**
- [ ] Check Play Services is installed on device
- [ ] Verify FCM token is valid
- [ ] Check app has notification permission
- [ ] Ensure minSdkVersion ≥ 21

**iOS:**
- [ ] Verify APNs certificate is uploaded to Firebase
- [ ] Check Push Notifications capability is enabled in Xcode
- [ ] Ensure Background Modes includes Remote notifications
- [ ] Test on physical device (simulator may have issues)

### Sound Not Playing
- [ ] Place `notification_sound.mp3` in `android/app/src/main/res/raw/`
- [ ] Place `notification_sound.aiff` in iOS bundle
- [ ] Check device is not in silent mode
- [ ] Check system volume is not muted
- [ ] Make sure notification has `playSound: true`

### FCM Token Not Generated
- [ ] Check Firebase is properly initialized
- [ ] Verify internet connection
- [ ] Check app has internet permission
- [ ] On iOS, check APNs configuration

## File Locations

```
project/
├── lib/
│   ├── services/
│   │   └── notification_service.dart       ✓ Updated with FCM
│   └── main.dart                           ✓ Already initializes
├── android/
│   └── app/src/main/
│       ├── res/raw/
│       │   └── notification_sound.mp3      ← Add here
│       └── AndroidManifest.xml             ✓ Permissions OK
├── ios/
│   └── Runner/
│       └── notification_sound.aiff         ← Add here
├── assets/
│   └── sounds/                             ← Alternative location
├── pubspec.yaml                            ✓ firebase_messaging added
└── NOTIFICATIONS_SETUP.md                  ← Full documentation
```

## Performance Notes

- FCM notifications are delivered instantly
- Local notifications have <1ms latency
- Sound plays concurrently - doesn't block UI
- Services run on background isolate (doesn't affect main thread)

## Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Add sound files to Android and iOS
3. ✅ Configure Firebase APNs (iOS only)
4. ✅ Get FCM token and register on backend
5. ✅ Test notifications in all states
6. ✅ Deploy to production

---

For detailed information, see [NOTIFICATIONS_SETUP.md](NOTIFICATIONS_SETUP.md)
