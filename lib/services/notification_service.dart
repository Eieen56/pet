import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'feeding_reminders';
  static const _channelName = 'Recordatorios de alimentación';
  static const _channelDescription =
      'Avisos antes y durante la hora de alimentación.';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _canScheduleExact = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await initialize();
    if (!Platform.isAndroid) {
      return;
    }
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    _canScheduleExact = await android?.canScheduleExactNotifications() ?? false;
    if (!_canScheduleExact) {
      await android?.requestExactAlarmsPermission();
      _canScheduleExact =
          await android?.canScheduleExactNotifications() ?? false;
    }
  }

  Future<void> syncAllForUser({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    await requestPermissions();
    await _notifications.cancelAll();
    final pets = await firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .get();
    for (final pet in pets.docs) {
      final name = pet.data()['name'] as String? ?? 'Mascota';
      final schedules = await pet.reference
          .collection('feedingSchedules')
          .get();
      for (final schedule in schedules.docs) {
        final data = schedule.data();
        await updateSchedule(
          petId: pet.id,
          petName: name,
          scheduleId: schedule.id,
          time: data['time'] as String? ?? '00:00',
          active: data['active'] as bool? ?? false,
        );
      }
    }
  }

  Future<void> updateSchedule({
    required String petId,
    required String petName,
    required String scheduleId,
    required String time,
    required bool active,
  }) async {
    await initialize();
    await cancelSchedule(petId: petId, scheduleId: scheduleId);
    if (!active) {
      return;
    }

    final parts = time.split(':');
    final mealMinutes = (int.parse(parts[0]) * 60) + int.parse(parts[1]);
    final beforeMinutes = (mealMinutes - 5) % (24 * 60);
    final mode = _canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notifications.zonedSchedule(
      id: notificationId(petId, scheduleId, 'before'),
      title: 'Próxima comida',
      body: 'Mascota "$petName" come en 5 minutos.',
      scheduledDate: _nextTime(beforeMinutes),
      notificationDetails: _details,
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$petId|$scheduleId',
    );
    await _notifications.zonedSchedule(
      id: notificationId(petId, scheduleId, 'meal'),
      title: 'Hora de alimentar',
      body: 'Es hora de alimentar a "$petName".',
      scheduledDate: _nextTime(mealMinutes),
      notificationDetails: _details,
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '$petId|$scheduleId',
    );
  }

  Future<void> cancelSchedule({
    required String petId,
    required String scheduleId,
  }) async {
    await initialize();
    await _notifications.cancel(
      id: notificationId(petId, scheduleId, 'before'),
    );
    await _notifications.cancel(id: notificationId(petId, scheduleId, 'meal'));
  }

  Future<void> cancelAll() async {
    await initialize();
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pendingRequests() async {
    await initialize();
    return _notifications.pendingNotificationRequests();
  }

  static int notificationId(String petId, String scheduleId, String kind) {
    var hash = 0x811c9dc5;
    for (final byte in '$petId:$scheduleId:$kind'.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  tz.TZDateTime _nextTime(int minutesSinceMidnight) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );
}
