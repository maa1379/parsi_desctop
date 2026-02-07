import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:parsi/provider/check_internet_connection.dart';
import 'package:parsi/provider/vpn_changer_state_service.dart';
import '../core/PrefHelper/PrefHelpers.dart';
import '../core/network/api_service.dart';
import '../models/configs_model.dart';

import 'package:flutter_v2ray_client_desktop/flutter_v2ray_client_desktop.dart' as desktop;

class ServerProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  late ConfigModel configsList;
  bool loading = false;
  bool firstTimeOfflineError = false;

  // تابع کمکی برای پارس کردن لینک بر اساس پلتفرم
  Future<String> _getParsedConfig(String link) async {
        final parser = desktop.V2rayParser();
      await parser.parse(link);
      return parser.json();
  }

  void getAllConfigs() async {
    try {
      final res = await api.getAllConfig();
      if (res.statusCode == 200) {
        configsList = ConfigModel.fromJson(res.data['data']);
        await ConfigModel.saveToDB(configsList.config);

        if (await PrefHelpers.getServerConfig() == null) {
          // استفاده از تابع پارسر جدید
          String fullConfig = await _getParsedConfig(configsList.config[0].configLink);

          await PrefHelpers.setServerConfig(fullConfig);
          await PrefHelpers.setServerConfigUri(configsList.config[0].configLink);
          await PrefHelpers.setActiveServer(configsList.config[0].serverName);
          await PrefHelpers.setServerFlag(configsList.config[0].serverFlagPath);
          await PrefHelpers.setServerAddress(configsList.config[0].serverIp);
        }

        String server = await PrefHelpers.getServerConfig() ?? "";
        if (server.startsWith("[Interface]")) {
          vpnStateNotifier.value = VpnState.wireGuardState;
        } else {
          vpnStateNotifier.value = VpnState.v2rayState;
        }
        loading = true;
        notifyListeners();
      } else {
        await _loadFromDb();
      }
    } catch (e) {
      debugPrint("Error getAllConfigs: $e");
      await _loadFromDb();
    }
  }

  void parseServerConfig(
      String link,
      String serverName,
      String serverFlagPath,
      String serverIp,
      ) async {
    // بروزرسانی پارس کانفیگ در اینجا
    String fullConfig = await _getParsedConfig(link);

    await PrefHelpers.setServerConfig(fullConfig);
    await PrefHelpers.setServerConfigUri(link);
    await PrefHelpers.setActiveServer(serverName);
    await PrefHelpers.setServerFlag(serverFlagPath);
    await PrefHelpers.setServerAddress(serverIp);
    notifyListeners();
  }

  // متد WireGuard بدون تغییر باقی می‌ماند چون پارسر مجزا ندارد
  void parseWireGuardServerConfig(
      String link,
      String serverName,
      String serverFlagPath,
      String serverIp,
      String serverEndPoint,
      ) async {
    await PrefHelpers.setServerConfig(link);
    await PrefHelpers.setServerConfigUri(link);
    await PrefHelpers.setActiveServer(serverName);
    await PrefHelpers.setServerFlag(serverFlagPath);
    await PrefHelpers.setServerAddress(serverIp);
    await PrefHelpers.setServerEndPoint(serverEndPoint);
    notifyListeners();
  }

  Future<void> _loadFromDb() async {
    configsList = (await ConfigModel.getDB())!;
    if (configsList == null) {
      firstTimeOfflineError = true;
    } else {
      loading = true;
    }
    notifyListeners();
  }

  Future initData() async {
    firstTimeOfflineError = false;
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      configsList = (await ConfigModel.getDB())!;
      if (configsList == null) {
        firstTimeOfflineError = true;
      }
      loading = true;
      notifyListeners();
    } else {
      if (await ConfigModel.getDB() != null) {
        configsList = (await ConfigModel.getDB())!;
        loading = true;
        notifyListeners();
      }
      getAllConfigs();
    }
  }
}