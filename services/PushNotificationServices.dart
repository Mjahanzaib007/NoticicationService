import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foodle/app/config/global_var.dart';
import 'package:foodle/app/routes/app_pages.dart';
import 'package:foodle/app/services/LocalNotificationHandler.dart';
import 'package:foodle/presentation/profile/views/foreign_profile_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/foodle_video.dart';
import '../../data/repositories/videos_repository.dart';

class FirebasePushNotificationHandler {
  late SharedPreferences pref;
  final VideosRepository _repository = VideosRepository();
  setUpFirebasePushNotification() async {
    print('FirebasePushNotificationHandler.setUpFirebasePushNotification');
    LocalNotificationHandler local = LocalNotificationHandler();
    Get.log(
        '[FirebasePushNotificationHandler.setUpFirebasePushNotification] called ');
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    Get.log('[FirebasePushNotificationHandler.requestPermission] called ${settings.authorizationStatus}   ');
    // NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    setupInteractedMessage();
    pref = await SharedPreferences.getInstance();
    String? token = await firebaseMessaging.getToken();
    Globals.fcmToken = token!;
    pref.setString("fcmToken", token);
    print("fcmToken : $token");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((event) {
      Get.log('[FirebasePushNotificationHandler.onMessage] Listening called ');
      RemoteNotification? notification = event.notification;
      local.initilizeLocalNotification().then((value) {
        local.displayLocalNotification(notification!, event.data);
      });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Get.log(
          '[FirebasePushNotificationHandler.onMessageOpenedApp] Listening called ');
      print(event);
      RemoteNotification? notification = event.notification;
      local.initilizeLocalNotification().then((value) {
        local.displayLocalNotification(notification!, event.data);
      });
    });
  }

  Future<void> setupInteractedMessage() async {
    Get.log('[FirebasePushNotificationHandler.setupInteractedMessage] called ');
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Get.log(
        '[FirebasePushNotificationHandler._handleMessage] called ${message.data}');
    // Config.fromNotification = true;
    // Get.offAll(() => const Notifications());

    // print("CONVERTING FROM NOTIFICATION VALUE TO ${Config.fromNotification}");
    if (message.data['eventId'] == "0") {
      print("this is my message ${message.data}");
      Get.toNamed(Routes.NOTIFICATIONS);
    } else if (message.data['eventId'] == "1") {
      Get.log('[FirebasePushNotificationHandler._handleMessage] called 1');
      Get.to(() => ForeignProfilePageView(), arguments: message.data['userid']);
    } else if (message.data['eventId'] == "2") {
      Get.log('[FirebasePushNotificationHandler._handleMessage] called 2');
      getVideoById(int.parse(message.data['objectId']));
    } else if (message.data['eventId'] == "3") {
      Get.log('[FirebasePushNotificationHandler._handleMessage] called 3');
      getVideoById(int.parse(message.data['objectId']));
    } else if (message.data['eventId'] == "4") {
      Get.log('[FirebasePushNotificationHandler._handleMessage] called 4');
      getVideoById(int.parse(message.data['objectId']));
    } else if (message.data['eventId'] == "5") {
      Get.log('[FirebasePushNotificationHandler._handleMessage] called 5');
      Get.toNamed(Routes.MESSAGES);
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
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Get.log('[_firebaseMessagingBackgroundHandler] called ');
  await Firebase.initializeApp();
  print("Handling a background message: ${message.data}");
  // Get.offAll(() => const Notifications());

  if (message.data['eventType'] == "Order") {
    print("I AM CALLING ORDER FROM NOTIFICATION");

    // Navigator.of(globalContext).push(MaterialPageRoute(builder: (context) {
    //   return Orders();
    // }));
  }
}
