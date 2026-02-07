import 'dart:convert';

import '../core/PrefHelper/PrefHelpers.dart';

class PopUpModel {
  Last last;

  PopUpModel({
    required this.last,
  });

  factory PopUpModel.fromJson(Map<String, dynamic> json) => PopUpModel(
    last: Last.fromJson(json["last"]),
  );


  static Future<void> saveToDB(PopUpModel popUp) async {
    await PrefHelpers.setPopUpModel(popUp);
  }


  static Future<PopUpModel?> getDB() async {
    String p = await PrefHelpers.getPopUpModel() ?? "null";
    if(p != "null"){
      final data = jsonDecode(p);
      return PopUpModel.fromJson(data);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "last": last.toJson(),
  };
}

class Last {
  String id;
  String popUpPath;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Last({
    required this.id,
    required this.popUpPath,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Last.fromJson(Map<String, dynamic> json) => Last(
    id: json["_id"],
    popUpPath: json["popUp_path"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "popUp_path": popUpPath,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}
