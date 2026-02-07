import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class AccountInfoModel {
  List<Sub> sub;

  AccountInfoModel({
    required this.sub,
  });

  factory AccountInfoModel.fromJson(Map<String, dynamic> json) =>
      AccountInfoModel(
        sub: List<Sub>.from(json["sub"].map((x) => Sub.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sub": List<dynamic>.from(sub.map((x) => x.toJson())),
      };

  static Future<void> saveToDB(List<Sub> sub) async {
    await PrefHelpers.setInfoModel(sub);
  }

  static Future<AccountInfoModel?> getDB() async {
    if (await PrefHelpers.getInfoModel() == null) {
      return null;
    } else {
      String p = await PrefHelpers.getInfoModel();
      List<dynamic> data = jsonDecode(p);
      List<Sub> list = [];
      for (var i in data) {
        list.add(Sub.fromJson(i));
      }
      return AccountInfoModel(sub: list);
    }
  }
}

class Sub {
  String id;
  DateTime subDay;
  int subPeriodDay;
  String subCode;
  String note;
  List<String> userId;
  String phoneNumber;
  String buyerId;
  int activeSubCount;
  Period period;
  bool isPaid;
  String payId;
  bool isExpired;
  bool forOthers;
  bool trafficEnd;
  String upload;
  String traffic;
  String download;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Sub({
    required this.id,
    required this.subDay,
    required this.subPeriodDay,
    required this.note,
    required this.subCode,
    required this.userId,
    required this.buyerId,
    required this.forOthers,
    required this.phoneNumber,
    required this.traffic,
    required this.activeSubCount,
    required this.period,
    required this.isPaid,
    required this.payId,
    required this.isExpired,
    required this.trafficEnd,
    required this.upload,
    required this.download,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Sub.fromJson(Map<String, dynamic> json) => Sub(
        id: json["_id"],
        subDay: DateTime.parse(json["sub_day"]),
        subPeriodDay: json["sub_period_day"],
        note: json["note"] ?? "",
        subCode: json["sub_code"],
    traffic: json["traffic"] ?? "0",
    buyerId: json["buyer_id"],
        forOthers: json["for_others"],
        userId: List<String>.from(json["user_id"].map((x) => x)),
        phoneNumber: json["phone_number"] ?? "",
        activeSubCount: json["active_sub_count"],
        period: Period.fromJson(json["period"]),
        isPaid: json["isPaid"],
        payId: json["payId"],
        isExpired: json["isExpired"],
        trafficEnd: json["traffic_end"],
        upload: json["upload"] ?? "0",
        download: json["download"] ?? "0",
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "sub_day": subDay.toIso8601String(),
        "sub_period_day": subPeriodDay,
        "sub_code": subCode,
        "for_others": forOthers,
        "note": note,
        "traffic": traffic,
        "user_id": userId,
        "buyer_id": buyerId,
        "phone_number": phoneNumber,
        "active_sub_count": activeSubCount,
        "period": period.toJson(),
        "isPaid": isPaid,
        "payId": payId,
        "isExpired": isExpired,
        "traffic_end": trafficEnd,
        "upload": upload,
        "download": download,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };

  static Future<void> saveToDB(Sub sub) async {
    await PrefHelpers.setSubModel(sub);
  }

  static Future<Sub?> getDB() async {
    String p = await PrefHelpers.getSubModel() ?? "null";
    if (p != "null") {
      final data = jsonDecode(p);
      return Sub.fromJson(data);
    }
    return null;
  }
}

class Period {
  String id;
  String periodName;
  int periodDay;
  int periodHour;
  int periodPrice;
  int v;
  bool isFree;
  dynamic traffic;
  int subCount;

  Period({
    required this.id,
    required this.periodName,
    required this.periodDay,
    required this.periodHour,
    required this.isFree,
    required this.periodPrice,
    required this.v,
    required this.traffic,
    required this.subCount,
  });

  factory Period.fromJson(Map<String, dynamic> json) => Period(
        id: json["_id"],
        periodName: json["period_name"],
        periodDay: json["period_day"],
        periodHour: json["period_hour"].toInt(),
        isFree: json["is_free"] ?? false,
        periodPrice: json["period_price"],
        v: json["__v"],
        traffic: json["traffic"],
        subCount: json["sub_count"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "period_name": periodName,
        "is_free": isFree,
        "period_hour": periodHour,
        "period_day": periodDay,
        "period_price": periodPrice,
        "__v": v,
        "traffic": traffic,
        "sub_count": subCount,
      };
}
