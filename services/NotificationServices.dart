// import 'package:dio/dio.dart';
// import 'package:feelaska/Globalvariables.dart';
// import 'package:feelaska/Models/Notification.dart';
// import 'package:feelaska/Utilities/config.dart';

// class NotificationServices {
//   Future<List<NotificationModel>> fetchAllNotifications() async {
//     List<NotificationModel> tempNotifications = [];
//     try {
//       int pageNumber = 1;
//       int pageSize = 10;
//       var response = await Dio().get(
//         baseUrl +
//             '/api/UserNotification/GetNotificationsByUserId?row=$pageNumber&page=$pageSize',
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             'Authorization': 'Bearer ${Config.userToken}'
//           },
//           followRedirects: false,
//           validateStatus: (status) {
//             return status <= 500;
//           },
//         ),
//       );
//       print("THIS IS MY REPONSE FROM NS ${response.statusCode}");
//       var body = response.data['payload'];
//       if (response.statusCode == 200) {
//         body.forEach((element) {
//           print(element);
//           tempNotifications.add(NotificationModel.fromJson(element));
//         });
//         return tempNotifications;
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }
// }
