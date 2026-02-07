import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class ConfigModel {
  List<Config> config;

  ConfigModel({
    required this.config,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        config:
            List<Config>.from(json["config"].map((x) => Config.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "config": List<dynamic>.from(config.map((x) => x.toJson())),
      };

  static Future<void> saveToDB(List<Config> config) async {
    await PrefHelpers.setConfigModel(config);
  }

  static Future<ConfigModel?> getDB() async {
    if (await PrefHelpers.getConfigModel() == null) {
      await PrefHelpers.setConfigModel([
        Config(
            id: "1",
            configLink:
                "vless://51a3ab6e-9c49-45b4-b187-6f3bd661aa2e@france1.parsi.sbs:29918?security=none&encryption=none&host=speedtest.net&headerType=http&type=tcp#%D9%81%D8%B1%D8%A7%D9%86%D8%B3%D9%87",
            serverFlagPath: "",
            serverIp: "France1.parsi.sbs",
            serverName: "فرانسه",
            userCount: 500,
            wireGuardEndPoint: "",
            configType: "V2ray",
            v: 0)
      ]);
      String p = await PrefHelpers.getConfigModel();
      List<dynamic> data = jsonDecode(p);
      List<Config> list = [];
      for (var i in data) {
        list.add(Config.fromJson(i));
      }
      return ConfigModel(config: list);
    } else {
      String p = await PrefHelpers.getConfigModel();
      List<dynamic> data = jsonDecode(p);
      List<Config> list = [];
      for (var i in data) {
        list.add(Config.fromJson(i));
      }
      return ConfigModel(config: list);
    }
  }
}

class Config {
  String id;
  String serverName;
  String serverIp;
  int userCount;
  String serverFlagPath;
  String configLink;
  String wireGuardEndPoint;
  String configType;
  int v;
  int? ping = 0;

  Config({
    required this.id,
    this.ping,
    required this.serverName,
    required this.serverIp,
    required this.userCount,
    required this.wireGuardEndPoint,
    required this.configType,
    required this.serverFlagPath,
    required this.configLink,
    required this.v,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        id: json["_id"],
        serverName: json["server_name"],
        serverIp: json["server_ip"],
        wireGuardEndPoint: json["wireGuard_end_point"] ?? "",
        configType: json["config_type"] ?? "V2ray",
        userCount: json["user_count"],
        serverFlagPath: json["server_flag_path"] ?? "",
        configLink: json["config_Link"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "server_name": serverName,
        "server_ip": serverIp,
        "user_count": userCount,
        "wireGuard_end_point": wireGuardEndPoint,
        "config_type": configType,
        "server_flag_path": serverFlagPath,
        "config_Link": configLink,
        "__v": v,
      };
}



class TrainingModel {
  final String id;
  final String title;
  final String videoLink;

  TrainingModel({
    required this.id,
    required this.title,
    required this.videoLink,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['_id'] ?? '', // معمولا مونگوس _id برمی‌گرداند
      title: json['title'] ?? 'بدون عنوان',
      videoLink: json['videoLink'] ?? '',
    );
  }
}


class FAQModel {
  final String id;
  final String question;
  final String answer;

  FAQModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}