import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:enderase/enderase.dart';
import 'package:enderase/utils/firebase_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/storage_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/ic_stat_name', [
    NotificationChannel(
      channelKey: 'pill_reminder_channel',
      criticalAlerts: true,
      channelName: 'Pill Reminders',
      defaultColor: const Color(0xFF33EEC8),
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'Basic Notifications',
    ),
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      defaultColor: const Color(0xFF33EEC8),
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'Basic Notifications',
    ),
    NotificationChannel(
      channelKey: 'channel id',
      channelName: 'Basic Notifications',
      defaultColor: const Color(0xFF33EEC8),
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'Basic Notifications',
    ),
    NotificationChannel(
      channelKey: 'scheduled_channel',
      channelName: 'Scheduled Notifications',
      defaultColor: const Color(0xFF33EEC8),
      locked: true,
      importance: NotificationImportance.High,
      channelDescription: 'Scheduled Notifications',
    ),
  ]);
  if (Firebase.apps.isEmpty) {
    print("apps: ${Firebase.apps.length}");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseHandler().initNotifications();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    var set = await AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceived,
    );
    print('SETTING ON ACTION RECEIVED: $set');
  });
  await ConfigPreference.init();
  runApp(const Enderase());
}
