import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/setting_model.dart';
import '../../models/account_info_model.dart' as info;
import '../../models/configs_model.dart';
import '../../models/notification_model.dart';
import '../../models/period_model.dart';
import '../../models/pop_up_model.dart' as popUp;
import 'Prefs.dart';

class PrefHelpers {
  static Future<void> setToken(String token) async {
    await Prefs.set('token', token);
  }

  static Future getToken() async {
    return await Prefs.get('token');
  }

  static Future removeToken() async {
    return await Prefs.clear('token');
  }

  static Future<void> setWalletId(String walletId) async {
    await Prefs.set('walletId', walletId);
  }

  static Future getWalletId() async {
    return await Prefs.get('walletId');
  }

  static Future removeWalletId() async {
    return await Prefs.clear('walletId');
  }

  static Future<void> setServerAddress(String ip) async {
    await Prefs.set('ip', ip);
  }

  static Future getServerAddress() async {
    return await Prefs.get('ip');
  }

  static Future removeServerAddress() async {
    return await Prefs.clear('ip');
  }

  static Future<void> setTraffic(String traffic) async {
    await Prefs.set('traffic', traffic);
  }

  static Future getTraffic() async {
    return await Prefs.get('traffic');
  }

  static Future removeTraffic() async {
    return await Prefs.clear('traffic');
  }

  static Future<void> setActiveServer(String server) async {
    await Prefs.set('server', server);
  }

  static Future getActiveServer() async {
    return await Prefs.get('server');
  }

  static Future removeActiveServer() async {
    return await Prefs.clear('server');
  }

  static Future<void> setServerFlag(String flag) async {
    await Prefs.set('flag', flag);
  }

  static Future getServerFlag() async {
    return await Prefs.get('flag');
  }

  static Future removeServerFlag() async {
    return await Prefs.clear('flag');
  }

  static Future<void> setServerConfig(String serverConfig) async {
    await Prefs.set('serverConfig', serverConfig);
  }

  static Future getServerConfig() async {
    return await Prefs.get('serverConfig');
  }

  static Future removeServerConfig() async {
    return await Prefs.clear('serverConfig');
  }

  static Future<void> setServerConfigUri(String serverConfigUri) async {
    await Prefs.set('serverConfigUri', serverConfigUri);
  }

  static Future getServerConfigUri() async {
    return await Prefs.get('serverConfigUri');
  }

  static Future removeServerConfigUri() async {
    return await Prefs.clear('serverConfigUri');
  }

  static Future<void> setServerEndPoint(String endPoint) async {
    await Prefs.set('endPoint', endPoint);
  }

  static Future getServerEndPoint() async {
    return await Prefs.get('endPoint');
  }

  static Future removeServerEndPoint() async {
    return await Prefs.clear('endPoint');
  }

  static Future<void> setDeviceId(String device) async {
    await Prefs.set('device', device);
  }

  static Future getDeviceId() async {
    return await Prefs.get('device');
  }

  static Future removeDeviceId() async {
    return await Prefs.clear('device');
  }

  static Future<void> setUserId(String id) async {
    await Prefs.set('id', id);
  }

  static Future getUserId() async {
    return await Prefs.get('id');
  }

  static Future removeUserId() async {
    return await Prefs.clear('id');
  }

  static Future<void> setTrafficUsed(String trafficUsed) async {
    await Prefs.set('trafficUsed', trafficUsed);
  }

  static Future getTrafficUsed() async {
    return await Prefs.get('trafficUsed');
  }

  static Future removeTrafficUsed() async {
    return await Prefs.clear('trafficUsed');
  }

  static Future<void> setSubCode(String code) async {
    await Prefs.set('code', code);
  }

  static Future getSubCode() async {
    return await Prefs.get('code');
  }

  static Future removeSubCode() async {
    return await Prefs.clear('code');
  }

  static Future<void> setPeriodModel(List<Period> period) async {
    await Prefs.set('period', jsonEncode(period));
  }

  static Future getPeriodModel() async {
    return await Prefs.get('period');
  }

  static Future removePeriodModel() async {
    return await Prefs.clear('period');
  }

  static Future<void> setNotificationModel(
      NotificationModel notification) async {
    await Prefs.set('notification', jsonEncode(notification));
  }

  static Future getNotificationModel() async {
    return await Prefs.get('notification');
  }

  static Future removeNotificationModel() async {
    return await Prefs.clear('notification');
  }

  static Future<void> setConfigModel(List<Config> config) async {
    await Prefs.set('config', jsonEncode(config));
  }

  static Future getConfigModel() async {
    return await Prefs.get('config');
  }

  static Future removeConfigModel() async {
    return await Prefs.clear('config');
  }

  static Future<void> setInfoModel(List<info.Sub> sub) async {
    await Prefs.set('sub', jsonEncode(sub));
  }

  static Future getInfoModel() async {
    return await Prefs.get('sub');
  }

  static Future removeInfoModel() async {
    return await Prefs.clear('sub');
  }

  static Future<void> setSubModel(info.Sub subActive) async {
    await Prefs.set('subActive', jsonEncode(subActive));
  }

  static Future getSubModel() async {
    return await Prefs.get('subActive');
  }

  static Future removeSubModel() async {
    return await Prefs.clear('subActive');
  }

  static Future<void> setPopUpModel(popUp.PopUpModel popUp) async {
    await Prefs.set('popUp', jsonEncode(popUp));
  }

  static Future getPopUpModel() async {
    return await Prefs.get('popUp');
  }

  static Future removePopUpModel() async {
    return await Prefs.clear('popUp');
  }

  static Future<void> setSettingsModel(SettingModel settingsModel) async {
    await Prefs.set('settingsModel', jsonEncode(settingsModel));
  }

  static Future getSettingsModel() async {
    return await Prefs.get('settingsModel');
  }

  static Future removeSettingsModel() async {
    return await Prefs.clear('settingsModel');
  }


  static const String _lastSubCheckTimestampKey = "lastSubCheckTimestamp";

  static Future<void> setLastSubCheckTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSubCheckTimestampKey, timestamp);
  }

  static Future<String?> getLastSubCheckTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSubCheckTimestampKey);
  }

}
