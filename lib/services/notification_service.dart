import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/order_model.dart';

/// Service class for handling notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _soundEnabled = true;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip local notifications for web platform
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    try {
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
      );

      // Request permissions for Android 13+
      if (Platform.isAndroid) {
        await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = true; // Mark as initialized to prevent repeated attempts
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to order details
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show new order notification with sound
  Future<void> showNewOrderNotification(Order order) async {
    // Play notification sound first
    await _playNotificationSound();

    if (kIsWeb) {
      // For web, we can only play sound (already done above)
      debugPrint('New order received: ${order.id}');
      return;
    }

    if (!_isInitialized) await initialize();

    try {
      // Android notification details with sound
      const androidDetails = AndroidNotificationDetails(
        'new_orders_channel',
        'New Orders',
        channelDescription: 'Notifications for new orders received',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(''),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '🛒 New Order Received!',
        'Order #${order.shortId} - ${order.customerName}\nTotal: ₹${order.totalPrice.toStringAsFixed(2)}',
        notificationDetails,
        payload: order.id,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Show order status update notification
  Future<void> showOrderStatusNotification(Order order) async {
    if (kIsWeb) return;
    if (!_isInitialized) await initialize();

    try {
      final statusText = _getStatusText(order.status);

      const androidDetails = AndroidNotificationDetails(
        'order_updates_channel',
        'Order Updates',
        channelDescription: 'Notifications for order status updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
        'Order Status Updated',
        'Order #${order.shortId} is now $statusText',
        notificationDetails,
        payload: order.id,
      );
    } catch (e) {
      debugPrint('Error showing status notification: $e');
    }
  }

  /// Play notification sound
  Future<void> _playNotificationSound() async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.setVolume(1.0);
      // Play custom notification sound from assets
      await _audioPlayer.play(AssetSource('sounds/tone.mp3'));
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
    _audioPlayer.dispose();
  }
}
