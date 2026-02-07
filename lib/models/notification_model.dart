import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class NotificationModel {
  List<NotificationItem> myNotification;
  List<NotificationItem> localNotification;

  NotificationModel({
    required this.myNotification,
    required this.localNotification,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        myNotification: List<NotificationItem>.from(
            json["myNotification"].map((x) => NotificationItem.fromJson(x))),
        localNotification: List<NotificationItem>.from(
            json["localNotification"].map((x) => NotificationItem.fromJson(x))),
      );


  static Future<void> saveToDB(NotificationModel notification) async {
    await PrefHelpers.setNotificationModel(notification);
  }

  static Future<NotificationModel> getDB() async {
    String p = await PrefHelpers.getPeriodModel();
    final data = jsonDecode(p);
    return NotificationModel.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        "myNotification":
            List<dynamic>.from(myNotification.map((x) => x.toJson())),
        "localNotification":
            List<dynamic>.from(localNotification.map((x) => x.toJson())),
      };
}

class NotificationItem {
  String id;
  String title;
  String body;
  String? deviceInfo;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json["_id"] ?? "",
        title: json["title"] ?? "",
        body: json["body"] ?? "",
        deviceInfo: json["deviceInfo"] ?? "",
        createdAt: DateTime.parse(json["createdAt"] ?? DateTime.now()),
        updatedAt: DateTime.parse(json["updatedAt"] ?? DateTime.now()),
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "body": body,
        "deviceInfo": deviceInfo,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
