import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodle/data/models/foodle_video.dart';
import 'package:foodle/data/repositories/videos_repository.dart';
import 'package:get/get.dart';

import '../../presentation/profile/views/foreign_profile_view.dart';
import '../routes/app_pages.dart';

class LocalNotificationHandler {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final VideosRepository _repository = VideosRepository();

  LocalNotificationHandler() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future initilizeLocalNotification() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    flutterLocalNotificationsPlugin?.initialize(initializationSettings,
        onDidReceiveNotificationResponse: selectNotification);
  }

  void selectNotification(NotificationResponse response) async {
    Get.log('[LocalNotificationHandler.selectNotification] called ');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    // Get.to(() => const Notifications());

    if (response.payload != null) {
      if (response.payload!.split(":")[1] == "0") {
        print("this is my message $response.payload");
        Get.toNamed(Routes.NOTIFICATIONS);
      } else if (response.payload!.split(":")[1] == "1") {
        Get.to(() => ForeignProfilePageView(),
            arguments: response.payload!.split(":")[2]);
      } else if (response.payload!.split(":")[1] == "2") {
        Get.log('[FirebasePushNotificationHandler._handleMessage] called ');
        getVideoById(int.parse(response.payload!.split(":")[0]));
      } else if (response.payload!.split(":")[1] == "3") {
        Get.log('[FirebasePushNotificationHandler._handleMessage] called ');
        getVideoById(int.parse(response.payload!.split(":")[0]));
      } else if (response.payload!.split(":")[1] == "4") {
        Get.log('[FirebasePushNotificationHandler._handleMessage] called ');
        getVideoById(int.parse(response.payload!.split(":")[0]));
      } else if (response.payload!.split(":")[1] == "5") {
        Get.log('[FirebasePushNotificationHandler._handleMessage] called ');
        Get.toNamed(Routes.MESSAGES);
      }
    }
  }

  Future getVideoById(int id) async {
    Map<String, dynamic>? resp;
    try {
      resp = await _repository.getVideoById(id);
    } catch (e) {
      Get.log('[HomeController.getSavedPlaylistCollection] called ');
    }
    if (resp != null && resp['status'] == "Success") {
      FoodleVideo video = FoodleVideo.fromJson(resp['payload']);
      Get.toNamed(Routes.PROFILE_VIDEO_PLAYER, arguments: [
        0,
        [video]
      ]);
    } else if (resp != null && resp['status'] == "Fail") {
      print("failed");
      print(resp);
    } else {}
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    Get.log(
        '[LocalNotificationHandler.onDidReceiveLocalNotification] called $title $body');
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ""),
        content: Text("Foodle"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  displayLocalNotification(
      RemoteNotification remoteNotification, Map<String, dynamic> data) async {
    Get.log('[LocalNotificationHandler.displayLocalNotification] called ');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: "textCategory",
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(0, remoteNotification.title,
        remoteNotification.body, platformChannelSpecifics,
        payload: '${data['objectId']}:${data['eventId']}:${data['userid']}');
  }
}
