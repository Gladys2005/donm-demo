import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();
  
  static Stream<RemoteMessage> get messageStream => _messageStreamController.stream;
  
  static Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();
    
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }
  
  static Future<void> _requestPermissions() async {
    // Request notification permission
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    // Request system permissions
    await [
      Permission.notification,
    ].request();
  }
  
  static Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await StorageService.saveDeviceToken(fcmToken);
      debugPrint('FCM Token: $fcmToken');
    }
    
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      StorageService.saveDeviceToken(token);
      debugPrint('FCM Token refreshed: $token');
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _messageStreamController.add(message);
    });
    
    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _messageStreamController.add(message);
    });
    
    // Handle initial message (app opened from terminated state)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _messageStreamController.add(initialMessage);
    }
  }
  
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_updates',
      'Order Updates',
      description: 'Notifications about order status changes',
      importance: Importance.high,
      enableLights: true,
      ledColor: AppConfig.primaryColor,
      playSound: true,
    );
    
    const AndroidNotificationChannel paymentChannel = AndroidNotificationChannel(
      'payment_updates',
      'Payment Updates',
      description: 'Notifications about payment status changes',
      importance: Importance.high,
      enableLights: true,
      ledColor: AppConfig.successColor,
      playSound: true,
    );
    
    const AndroidNotificationChannel kycChannel = AndroidNotificationChannel(
      'kyc_updates',
      'KYC Updates',
      description: 'Notifications about KYC verification status',
      importance: Importance.default,
      enableLights: true,
      ledColor: AppConfig.infoColor,
      playSound: true,
    );
    
    const AndroidNotificationChannel promoChannel = AndroidNotificationChannel(
      'promotions',
      'Promotions',
      description: 'Special offers and promotions',
      importance: Importance.low,
      enableLights: false,
      playSound: false,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(paymentChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kycChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promoChannel);
  }
  
  static Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    
    if (notification == null) return;
    
    // Determine channel based on data or notification type
    String channelId = 'general';
    if (data['type'] == 'ORDER_UPDATE') {
      channelId = 'order_updates';
    } else if (data['type'] == 'PAYMENT_UPDATE') {
      channelId = 'payment_updates';
    } else if (data['type'] == 'KYC_UPDATE') {
      channelId = 'kyc_updates';
    } else if (data['type'] == 'PROMOTION') {
      channelId = 'promotions';
    }
    
    await _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          channelDescription: 'DonM Notification',
          icon: '@mipmap/ic_launcher',
          color: AppConfig.primaryColor,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          autoCancel: true,
          actions: _getNotificationActions(data),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
        ),
      ),
      payload: _buildPayload(data),
    );
  }
  
  static List<AndroidNotificationAction> _getNotificationActions(Map<String, dynamic> data) {
    final actions = <AndroidNotificationAction>[];
    
    if (data['type'] == 'ORDER_UPDATE') {
      actions.add(
        const AndroidNotificationAction(
          'view_order',
          'View Order',
          showsUserInterface: true,
        ),
      );
    } else if (data['type'] == 'PAYMENT_UPDATE') {
      actions.add(
        const AndroidNotificationAction(
          'view_payment',
          'View Payment',
          showsUserInterface: true,
        ),
      );
    }
    
    return actions;
  }
  
  static String _buildPayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = <String, String>{};
      for (final pair in payload.split('&')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          data[parts[0]] = parts[1];
        }
      }
      
      _handleNotificationAction(response.actionId, data);
    }
  }
  
  static void _handleNotificationAction(String? action, Map<String, String> data) {
    // Handle notification actions
    switch (action) {
      case 'view_order':
        // Navigate to order details
        final orderId = data['order_id'];
        if (orderId != null) {
          navigatorKey.currentState?.pushNamed('/orders/$orderId');
        }
        break;
      case 'view_payment':
        // Navigate to payment details
        final paymentId = data['payment_id'];
        if (paymentId != null) {
          navigatorKey.currentState?.pushNamed('/wallet/history');
        }
        break;
      default:
        // Handle default navigation
        final route = data['route'];
        if (route != null) {
          navigatorKey.currentState?.pushNamed(route);
        }
        break;
    }
  }
  
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general',
    AndroidNotificationAction? action,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          channelDescription: 'DonM Local Notification',
          icon: '@mipmap/ic_launcher',
          color: AppConfig.primaryColor,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          autoCancel: true,
          actions: action != null ? [action] : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
  
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String channelId = 'general',
  }) async {
    await _notifications.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      TZDateTime.from(scheduledTime, local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          channelDescription: 'DonM Scheduled Notification',
          icon: '@mipmap/ic_launcher',
          color: AppConfig.primaryColor,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  static Future<void> getNotificationAppLaunchDetails() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null) {
      debugPrint('Notification launched app: ${details.notificationResponse.payload}');
    }
  }
  
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'device_type': 'ANDROID',
        'device_id': androidInfo.id,
        'device_name': '${androidInfo.brand} ${androidInfo.model}',
        'app_version': packageInfo.version,
        'os_version': '${androidInfo.version.release}',
      };
    } else {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'device_type': 'IOS',
        'device_id': iosInfo.identifierForVendor ?? 'unknown',
        'device_name': iosInfo.name ?? 'iOS Device',
        'app_version': packageInfo.version,
        'os_version': iosInfo.systemVersion,
      };
    }
  }
  
  static Future<void> registerDeviceToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final deviceInfo = await getDeviceInfo();
        
        // Send token to backend
        // This would be implemented in your API service
        debugPrint('Registering device token: $fcmToken');
        debugPrint('Device info: $deviceInfo');
      }
    } catch (e) {
      debugPrint('Error registering device token: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  
  // Show a notification when message is received in background
  await NotificationService.showForegroundNotification(message);
}
