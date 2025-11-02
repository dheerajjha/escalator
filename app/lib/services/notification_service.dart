import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static FirebaseMessaging? _messaging;

  static Future<void> initialize() async {
    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize local notifications
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Request permission
      await _requestPermission();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Listen to token refresh events (iOS tokens may not be immediately available)
      FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
        debugPrint('🔄 FCM Token refreshed: ${token.substring(0, 20)}...');
        // Token refresh happens automatically, no need to update backend here
        // as it will be updated when the user logs in
      });
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      // Firebase not configured - app will work without notifications
    }
  }

  static Future<void> _requestPermission() async {
    if (_messaging == null) return;

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  static Future<String?> getToken() async {
    if (_messaging == null) return null;

    try {
      // Try to get the FCM token directly first
      debugPrint('Attempting to get FCM token...');
      var token = await _messaging!.getToken();

      if (token != null) {
        debugPrint('✅ FCM Token received: ${token.substring(0, 20)}...');
        return token;
      }

      // If direct attempt failed on iOS, try with APNs token approach
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint('Direct token fetch failed, trying APNs approach for iOS...');
        final apnsToken = await _messaging!.getAPNSToken();

        if (apnsToken != null) {
          debugPrint('APNs token received, retrying FCM token...');
          token = await _messaging!.getToken();
          if (token != null) {
            debugPrint('✅ FCM Token received after APNs: ${token.substring(0, 20)}...');
            return token;
          }
        } else {
          debugPrint('⚠️  APNs token not available yet (normal in debug builds)');
          debugPrint('Push notifications will work in production builds');
        }
      }

      debugPrint('⚠️  FCM Token not available - app will work without push notifications');
      return null;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? 'Escalator',
        message.notification!.body ?? '',
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    // Handle navigation based on notification data
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on notification payload
  }

  static Future<void> _showLocalNotification(
    String title,
    String body,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'escalator_channel',
      'Escalator Notifications',
      channelDescription: 'Notifications for work item escalations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
