import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class SettingModel {
  Last last;

  SettingModel({
    required this.last,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
        last: Last.fromJson(json["last"]),
      );


  static Future<void> saveToDB(SettingModel model) async {
    await PrefHelpers.setSettingsModel(model);
  }
  static Future<SettingModel?> getDB() async {
    String p = await PrefHelpers.getSettingsModel() ?? "null";
    if(p != "null"){
      final data = jsonDecode(p);
      return SettingModel.fromJson(data);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "last": last.toJson(),
      };
}

class Last {
  String id;
  int freeSubDay;
  int freeTraffic;
  int freeSubNumber;
  String appVersion;
  String appDownloadLink;
  String telegramLink;
  String aboutServers;
  String whatsAppLink;
  String telegramGroupLink;
  String telegramSupportLink;
  String onlineSupportLink;
  String siteLink;
  String instagramLink;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String apiServerLink;
  int highConsumptionUsersTraffic;

  Last({
    required this.id,
    required this.freeSubDay,
    required this.freeTraffic,
    required this.aboutServers,
    required this.whatsAppLink,
    required this.freeSubNumber,
    required this.siteLink,
    required this.telegramGroupLink,
    required this.appVersion,
    required this.telegramSupportLink,
    required this.onlineSupportLink,
    required this.appDownloadLink,
    required this.telegramLink,
    required this.instagramLink,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.apiServerLink,
    required this.highConsumptionUsersTraffic,
  });

  factory Last.fromJson(Map<String, dynamic> json) => Last(
        id: json["_id"],
        freeSubDay: json["free_sub_day"],
        siteLink: json["site_link"] ?? "",
        freeTraffic: json["free_traffic"],
        aboutServers: json["about_servers"],
        freeSubNumber: json["free_sub_number"],
        telegramGroupLink: json["telegram_group_link"] ?? "",
        telegramSupportLink: json["telegram_support_link"] ?? "",
        onlineSupportLink: json["online_support_link"] ?? "",
        appVersion: json["app_version"],
        appDownloadLink: json["app_download_link"] ?? "",
        telegramLink: json["telegram_link"] ?? "",
        instagramLink: json["instagram_link"] ?? "",
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        apiServerLink: json["api_server_link"],
        highConsumptionUsersTraffic: json["high_consumption_Users_traffic"],
    whatsAppLink: json["whatsAppLink"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "free_sub_day": freeSubDay,
        "free_traffic": freeTraffic,
        "site_link": siteLink,
        "free_sub_number": freeSubNumber,
        "about_servers": aboutServers,
        "telegram_group_link": telegramGroupLink,
        "telegram_support_link": telegramSupportLink,
        "online_support_link": onlineSupportLink,
        "app_version": appVersion,
        "app_download_link": appDownloadLink,
        "telegram_link": telegramLink,
        "instagram_link": instagramLink,
        "whatsAppLink": whatsAppLink,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "api_server_link": apiServerLink,
        "high_consumption_Users_traffic": highConsumptionUsersTraffic,
      };
}

