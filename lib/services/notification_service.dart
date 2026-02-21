// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/order_model.dart';

/// Service class for handling notifications with FCM and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _soundEnabled = true;
  late StreamSubscription _foregroundMessageSubscription;

  /// Initialize notification service with FCM and local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip for web platform
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase Cloud Messaging
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      debugPrint('✓ Notification service initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = true;
    }
  }

  /// Initialize local notification settings
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Request Android 13+ notification permissions
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      // Create notification channels
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels with sound
  Future<void> _createNotificationChannels() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      // Orders channel with sound
      const ordersChannel = AndroidNotificationChannel(
        'new_orders_channel',
        'New Orders',
        description: 'Notifications for new orders received',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      await android.createNotificationChannel(ordersChannel);

      // Updates channel
      const updatesChannel = AndroidNotificationChannel(
        'order_updates_channel',
        'Order Updates',
        description: 'Notifications for order status updates',
        importance: Importance.defaultImportance,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      await android.createNotificationChannel(updatesChannel);
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request user notification permissions
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          provisional: false,
          sound: true,
        );

    debugPrint('User FCM permission: ${settings.authorizationStatus}');

    // Handle foreground messages
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get and log FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      debugPrint('FCM Token refreshed: $fcmToken');
      // Here you would send the new token to your backend
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Payload: ${message.data}');

    // Show notification while app is in foreground
    _showRemoteNotification(message);
  }

  /// Handle background messages (static)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Payload: ${message.data}');

    // Show notification in background
    NotificationService()._showRemoteNotificationBackground(message);
  }

  /// Handle message when app is opened from terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    // Navigate to order details if order ID is in payload
    if (message.data.containsKey('orderId')) {
      debugPrint('Navigating to order: ${message.data['orderId']}');
      // Navigation will be handled by app's navigation logic
    }
  }

  /// Show remote notification in foreground
  Future<void> _showRemoteNotification(RemoteMessage message) async {
    // Play sound
    await _playNotificationSound();

    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        'new_orders_channel',
        'New Orders',
        channelDescription: 'Notifications for new orders received',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          notification.body ?? '',
          contentTitle: notification.title,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title ?? 'New Order',
        notification.body ?? '',
        notificationDetails,
        payload: data['orderId'] ?? message.messageId ?? '',
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Show remote notification in background
  Future<void> _showRemoteNotificationBackground(RemoteMessage message) async {
    // Play sound
    await _playNotificationSound();

    final notification = message.notification;
    final data = message.data;

    if (notification == null) {
      debugPrint('No notification in background message');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'new_orders_channel',
        'New Orders',
        channelDescription: 'Notifications for new orders received',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title ?? 'New Order',
        notification.body ?? '',
        notificationDetails,
        payload: data['orderId'] ?? message.messageId ?? '',
      );
    } catch (e) {
      debugPrint('Error showing background notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigation to order details would be handled by app's router
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
  }

  /// Show new order notification with complete order details
  Future<void> showNewOrderNotification(Order order) async {
    if (!_isInitialized) await initialize();

    // Play notification sound
    await _playNotificationSound();

    if (kIsWeb) {
      debugPrint('New order received: ${order.id}');
      return;
    }

    try {
      final title = '🛒 New Order Received!';
      final body =
          'Order #${order.shortId}\n${order.customerName}\n₹${order.totalPrice.toStringAsFixed(0)}';

      final androidDetails = AndroidNotificationDetails(
        'new_orders_channel',
        'New Orders',
        channelDescription: 'Notifications for new orders received',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatBigText: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create payload with order details
      final payload = _createOrderPayload(order);

      await _notifications.show(
        order.id.hashCode,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✓ Order notification sent for Order #${order.shortId}');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Show order status update notification
  Future<void> showOrderStatusNotification(Order order) async {
    if (!_isInitialized) await initialize();

    if (kIsWeb) return;

    try {
      final statusText = _getStatusText(order.status);
      final statusIcon = _getStatusIcon(order.status);

      final title = '$statusIcon Order Status Updated';
      final body =
          'Order #${order.shortId} is now $statusText\nCustomer: ${order.customerName}';

      const androidDetails = AndroidNotificationDetails(
        'order_updates_channel',
        'Order Updates',
        channelDescription: 'Notifications for order status updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payload = _createOrderPayload(order);

      await _notifications.show(
        order.id.hashCode + 1,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✓ Status notification sent for Order #${order.shortId}');
    } catch (e) {
      debugPrint('Error showing status notification: $e');
    }
  }

  /// Create order payload for notification
  String _createOrderPayload(Order order) {
    return '${order.id}|${order.shortId}|${order.customerName}|${order.totalPrice}|${order.status.value}';
  }

  /// Parse order payload from notification
  Map<String, dynamic>? parseOrderPayload(String payload) {
    try {
      final parts = payload.split('|');
      if (parts.length >= 5) {
        return {
          'orderId': parts[0],
          'shortId': parts[1],
          'customerName': parts[2],
          'totalPrice': double.tryParse(parts[3]) ?? 0.0,
          'status': parts[4],
        };
      }
    } catch (e) {
      debugPrint('Error parsing order payload: $e');
    }
    return null;
  }

  /// Play notification sound
  Future<void> _playNotificationSound() async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.setVolume(1.0);
      // Play custom notification sound from assets
      await _audioPlayer.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
      // Fallback to URL-based sound if asset fails
      try {
        await _audioPlayer.play(
          UrlSource(
            'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
          ),
        );
      } catch (e2) {
        debugPrint('Could not play fallback sound: $e2');
      }
    }
  }

  /// Enable or disable notification sound
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Get human-readable status text
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get status icon/emoji
  String _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.processing:
        return '🔄';
      case OrderStatus.shipped:
        return '📦';
      case OrderStatus.delivered:
        return '✅';
      case OrderStatus.cancelled:
        return '❌';
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _notifications.cancel(id);
  }

  /// Dispose resources
  void dispose() {
    _foregroundMessageSubscription.cancel();
    _audioPlayer.dispose();
  }
}
