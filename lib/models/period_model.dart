import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class PeriodModel {
  List<Period> period;

  PeriodModel({
    required this.period,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) => PeriodModel(
        period:
            List<Period>.from(json["period"].map((x) => Period.fromJson(x))),
      );

  static Future<void> saveToDB(List<Period> period) async {
    await PrefHelpers.setPeriodModel(period);
  }

  static Future<PeriodModel?> getDB() async {
    String p = await PrefHelpers.getPeriodModel() ?? "null";
    if (p == "null") {
      return null;
    } else {
      List<dynamic> data = jsonDecode(p);
      List<Period> list = [];
      for (var i in data) {
        list.add(Period.fromJson(i));
      }
      return PeriodModel(period: list);
    }
  }
}

class Period {
  String id;
  String periodName;
  int periodDay;
  String subCount;
  bool isFree;
  bool visible;
  dynamic traffic;
  int periodPrice;
  bool isSelected = false;

  Period({
    required this.id,
    required this.periodName,
    required this.isFree,
    required this.visible,
    required this.subCount,
    required this.periodDay,
    required this.traffic,
    required this.periodPrice,
  });

  factory Period.fromJson(Map<String, dynamic> json) => Period(
        id: json["_id"],
        periodName: json["period_name"],
        subCount: json["sub_count"].toString(),
        traffic: json["traffic"],
        visible: json["visible"] ?? true,
        periodDay: json["period_day"],
        isFree: json["is_free"],
        periodPrice: json["period_price"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "period_name": periodName,
        "period_day": periodDay,
        "sub_count": subCount,
        "visible": visible,
        "is_free": isFree,
        "period_price": periodPrice,
      };
}
