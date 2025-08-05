import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_project/utils/medication_refill_calculator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderFrequency { daily, weekly }

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static bool _isInitialized = false;

  // Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize timezone data first
      tz.initializeTimeZones();
      
      // Get the device's timezone and set it as local
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      print('✅ Timezone initialized: $timeZoneName');
      
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with settings
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // ✅ NEW: Initialize Firebase Messaging
      await _initializeFirebaseMessaging();
      
      // Request permissions for Android 13+
      await _requestPermissions();
      
      // Create notification channels
      await _createNotificationChannel();
      await _createRefillNotificationChannel();
      
      _isInitialized = true;
      print('✅ NotificationService initialized successfully');
      
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      // Set a fallback timezone if device timezone fails
      tz.setLocalLocation(tz.UTC);
      _isInitialized = true;
    }
  }

  // Ensure initialization before any notification operation
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Schedule daily recurring notification
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _ensureInitialized(); // Ensure initialization
      
      const androidDetails = AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // If the time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: data != null ? jsonEncode(data) : null,
        matchDateTimeComponents: DateTimeComponents.time, // This makes it daily
      );
      
      print('✅ Daily notification scheduled for: ${time.format(Get.context!)} (${scheduledTime.toString()})');
    } catch (e) {
      print('❌ Error scheduling daily notification: $e');
      rethrow;
    }
  }

  // Schedule notification for specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _ensureInitialized(); // Ensure initialization
      
      const androidDetails = AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      final scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: data != null ? jsonEncode(data) : null,
      );
      
      print('✅ Notification scheduled for: $scheduledTZTime');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _ensureInitialized(); // Ensure initialization
      
      const androidDetails = AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: data != null ? jsonEncode(data) : null,
      );
      
      print('✅ Immediate notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
      rethrow;
    }
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // Create notification channel
  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Channel for medication reminder notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle notification taps
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final type = data['type'];
        
        if (type == 'medication_reminder') {
          // Handle medication reminder tap
          print('Medication reminder tapped for patient: ${data['patientName']}');
          
          // You can navigate to specific screens here
          // Get.to(() => SomeScreen());
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('✅ Notification $id cancelled');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('✅ All notifications cancelled');
  }

  // Get all pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Test notification (for debugging)
  static Future<void> showTestNotification() async {
    await showNotification(
      id: 999,
      title: '🧪 Test Notification',
      body: 'This is a test notification!',
      data: {'type': 'test', 'message': 'Hello World!'},
    );
  }
  // Schedule automatic refill notification
  static Future<void> scheduleRefillNotification({
    required String medicationId,
    required String medicationName,
    required String patientName,
    required String quantity,
    required String instructions,
    DateTime? medicationStartDate,
  }) async {
    try {
      await _ensureInitialized(); // Ensure initialization
      
      final refillDate = MedicationRefillCalculator.calculateRefillNotificationDate(
        quantity: quantity,
        instructions: instructions,
        startDate: medicationStartDate,
      );

      if (refillDate == null) {
        print('❌ Could not calculate refill date for $medicationName');
        return;
      }

      if (refillDate.isBefore(DateTime.now())) {
        print('⚠️ Refill date is in the past for $medicationName, scheduling for 1 hour from now');
        final immediateRefillDate = DateTime.now().add(Duration(hours: 1));
        await _scheduleRefillNotificationAt(
          medicationId: medicationId,
          medicationName: medicationName,
          patientName: patientName,
          scheduledTime: immediateRefillDate,
          isUrgent: true,
        );
        return;
      }

      await _scheduleRefillNotificationAt(
        medicationId: medicationId,
        medicationName: medicationName,
        patientName: patientName,
        scheduledTime: refillDate,
        isUrgent: false,
      );

      print('✅ Refill notification scheduled for $medicationName on ${refillDate.toString()}');
    } catch (e) {
      print('❌ Error scheduling refill notification: $e');
      rethrow;
    }
  }

  // Private method to schedule the actual notification
  static Future<void> _scheduleRefillNotificationAt({
    required String medicationId,
    required String medicationName,
    required String patientName,
    required DateTime scheduledTime,
    required bool isUrgent,
  }) async {
    final notificationId = int.parse(medicationId.hashCode.toString().substring(0, 8));
    
    final title = isUrgent 
        ? '🚨 Urgent: Refill $medicationName'
        : '💊 Time to Refill $medicationName';
        
    final body = isUrgent
        ? '$patientName needs to refill $medicationName immediately!'
        : '$patientName should refill $medicationName soon - running low in 2 days';

    const androidDetails = AndroidNotificationDetails(
      'refill_channel',
      'Medication Refill Reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      color: Colors.orange,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    final scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTZTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'type': 'medication_refill',
        'medicationId': medicationId,
        'medicationName': medicationName,
        'patientName': patientName,
        'isUrgent': isUrgent,
      }),
    );
  }

  // Cancel refill notification for a specific medication
  static Future<void> cancelRefillNotification(String medicationId) async {
    final notificationId = int.parse(medicationId.hashCode.toString().substring(0, 8));
    await _localNotifications.cancel(notificationId);
    print('✅ Refill notification cancelled for medication: $medicationId');
  }

  // Create a separate channel for refill notifications
  static Future<void> _createRefillNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'refill_channel',
      'Medication Refill Reminders',
      description: 'Notifications for medication refills',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ✅ NEW: Initialize Firebase Cloud Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM permission granted');
      
      // Get FCM token for this device
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');
      
      // Save token to user's profile in Firestore
      if (token != null) {
        await _saveFCMTokenToUser(token);
      }
      
      // Listen for incoming messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle notification taps when app is closed/background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
    } else {
      print('❌ FCM permission denied');
    }
  }

  // ✅ NEW: Save FCM token to user's profile
  static Future<void> _saveFCMTokenToUser(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token saved to user profile');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ✅ NEW: Handle messages when app is in foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message received: ${message.notification?.title}');
    
    // Show local notification for foreground messages
    if (message.notification != null) {
      showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification!.title ?? 'Medication Reminder',
        body: message.notification!.body ?? 'Time to take your medication!',
        data: message.data,
      );
    }
  }

  // ✅ NEW: Handle notification taps
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    
    // Navigate to specific screen based on notification data
    final type = message.data['type'];
    if (type == 'medication_reminder') {
      // Navigate to medication screen
      // Get.to(() => MedicationScreen());
    }
  }

  // ✅ NEW: Schedule notification with frequency option
  static Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required ReminderFrequency frequency,
    int? dayOfWeek, // For weekly: 1=Monday, 7=Sunday
    Map<String, dynamic>? data,
  }) async {
    try {
      await _ensureInitialized();
      
      const androidDetails = AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime;

      if (frequency == ReminderFrequency.daily) {
        // Daily reminder
        scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        // If time has passed today, schedule for tomorrow
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          scheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: 
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: data != null ? jsonEncode(data) : null,
          matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        );

        print('✅ Daily notification scheduled for: ${time.format(Get.context!)}');

      } else if (frequency == ReminderFrequency.weekly && dayOfWeek != null) {
        // Weekly reminder
        scheduledTime = _getNextWeeklyTime(time, dayOfWeek);

        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          scheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: 
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: data != null ? jsonEncode(data) : null,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Weekly repeat
        );

        final dayName = _getDayName(dayOfWeek);
        print('✅ Weekly notification scheduled for: $dayName at ${time.format(Get.context!)}');
      }

    } catch (e) {
      print('❌ Error scheduling recurring notification: $e');
      rethrow;
    }
  }

  // ✅ NEW: Helper method to get next weekly occurrence
  static tz.TZDateTime _getNextWeeklyTime(TimeOfDay time, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Find the next occurrence of the specified day
    int daysUntilTarget = (dayOfWeek - scheduledTime.weekday) % 7;
    if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      daysUntilTarget = 7; // Next week if today but time has passed
    }

    return scheduledTime.add(Duration(days: daysUntilTarget));
  }

  // ✅ NEW: Helper method to get day name
  static String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  // ✅ NEW: Schedule weekly notification
  static Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required int dayOfWeek, // 1=Monday, 7=Sunday
    Map<String, dynamic>? data,
  }) async {
    return scheduleRecurringNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      frequency: ReminderFrequency.weekly,
      dayOfWeek: dayOfWeek,
      data: data,
    );
  }

  // ... rest of your existing methods remain the same ...
}