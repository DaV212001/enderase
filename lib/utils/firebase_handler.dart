import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';

import '../constants/pages.dart';

@pragma("vm:entry-point")
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    try {
      if (Platform.isIOS) {
        print("Requesting APNS token");
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        print('APNs Token: $apnsToken');
      }
      final fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fcmToken');
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Foreground message handling -> show local notification
    FirebaseMessaging.onMessage.listen((message) {
      Logger().d('Title: ${message.notification?.title}');
      Logger().d('Body: ${message.notification?.body}');
      Logger().d('Payload: ${message.data}');

      final data = message.data;
      final dynamic idRaw = data['booking_id'] ?? data['id'];
      final String? idStr = idRaw?.toString();
      final int notifId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );
      final String body = idStr != null
          ? 'Booking ID: $idStr has been accepted'
          : (message.notification?.body ?? 'You have a new update');

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: 'basic_channel',
          backgroundColor: Colors.green,
          title: message.notification?.title ?? 'Enderase',
          body: body,
          payload: {if (idStr != null) 'booking_id': idStr},
        ),
      );
    });

    // When app is opened from an FCM notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = message.data;
      final String? idStr = (data['booking_id'] ?? data['id'])?.toString();
      final int? id = idStr != null ? int.tryParse(idStr) : null;
      if (id != null) {
        Get.toNamed(AppRoutes.bookingDetailRoute, arguments: {'id': id});
      }
    });
  }
}

class NotificationService {
  @pragma("vm:entry-point")
  static Future<void> onActionReceived(ReceivedAction event) async {
    final bookingId = event.payload?['booking_id'];
    if (bookingId != null) {
      final int? id = int.tryParse(bookingId);
      if (id != null) {
        Get.toNamed(AppRoutes.bookingDetailRoute, arguments: {'id': id});
      }
    }
  }
}
