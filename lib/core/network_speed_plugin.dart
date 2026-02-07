import 'dart:async';

import 'package:flutter/services.dart';

// class NetworkSpeedPlugin {
//   final platform = const MethodChannel('com.parsi.parsi/speed');
//
//   Future<NetworkSpeedModel> getNetworkStats() async {
//     late NetworkSpeedModel dataModel;
//     final Map<String, int> stats =
//         await platform.invokeMethod('getNetworkSpeed');
//     print(stats);
//     dataModel = NetworkSpeedModel.fromJson(stats);
//     return dataModel;
//   }
// }

class NetworkSpeedModel {
  double? tx;
  double? rx;
  double? total;

  NetworkSpeedModel({
    this.tx,
    this.rx,
    this.total,
  });

  factory NetworkSpeedModel.fromJson(Map<String, dynamic> json) =>
      NetworkSpeedModel(
        tx: json["tx"] ?? 0.0,
        rx: json["rx"] ?? 0.0,
        total: json["total"] ?? 0.0,
      );
}
