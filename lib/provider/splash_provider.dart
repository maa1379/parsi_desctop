import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parsi/core/nav_helper.dart';
import '../core/network/api_service.dart';
import '../models/setting_model.dart';
import '../screens/main_screen.dart';
import '../screens/widgets/show_update_dialog.dart';
import 'check_internet_connection.dart';

class SplashProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  SettingModel? settingModel;
  bool firstTimeOfflineError = false; // New flag

  Future<void> _navigateToMain(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));
    if (context.mounted) {
      context.rTo(const MainScreen());
    }
  }

  Future<void> getSetting(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final res = await api.getSetting();
      if (res.statusCode == 200) {
        settingModel = SettingModel.fromJson(res.data['data']);
        await SettingModel.saveToDB(settingModel!);
        notifyListeners();

        if (packageInfo.version != settingModel!.last.appVersion) {
          if (context.mounted) {
            ShowUpdateDialog.showInitDialog(
                context, settingModel!.last.appDownloadLink);
          }
        } else {
          await _navigateToMain(context);
        }
      } else {
        debugPrint("Error getSetting: ${res.data['message']}");
        // If API fails, try to load from DB
        settingModel = await SettingModel.getDB();
        notifyListeners();
        _navigateToMain(context);
      }
    } catch (e) {
      debugPrint("Error getSetting catch: $e");
      // If network error, try to load from DB
      settingModel = await SettingModel.getDB();
      notifyListeners();
      _navigateToMain(context);
    }
  }

  void initData(BuildContext context) async {
    firstTimeOfflineError = false; // Reset flag
    bool check = await CheckInternetConnection.checkInternetConnection();
    if (check) {
      await getSetting(context);
    } else {
      // Offline mode
      settingModel = await SettingModel.getDB();
      if (settingModel == null) {
        // First time offline, DB is empty
        firstTimeOfflineError = true;
      }
      notifyListeners();
      // Still navigate to main, UI will handle the error message
      _navigateToMain(context);
    }
  }
}