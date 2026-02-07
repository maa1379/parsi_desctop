import 'package:flutter/cupertino.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:parsi/main.dart';
import 'package:parsi/provider/check_internet_connection.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:parsi/provider/v2ray_provider.dart';

import '../core/PrefHelper/PrefHelpers.dart';
import '../screens/widgets/showCooperationDialog.dart';

class BackgroundServiceProvider extends ChangeNotifier {
  // این پروایدرها باید از طریق ProxyProvider تزریق شوند
  UserProvider? _userProvider;
  VpnProvider? _vpnProvider;

  NeatPeriodicTaskScheduler? trafficScheduler;

  // NeatPeriodicTaskScheduler? statusScheduler;

  bool _isRunning = false;

  // این متد توسط ChangeNotifierProxyProvider صدا زده می‌شود
  void updateDependencies(UserProvider user, VpnProvider vpn) async{
    _userProvider = user;
    _vpnProvider = vpn;

    // اگر سرویس‌ها در حال اجرا نبودند، اجرا کن
    if (!_isRunning && _userProvider != null && _vpnProvider != null) {
      if(await CheckInternetConnection.checkInternetConnection() == true){
      _startTasks();
      }
    }
  }

  void _startTasks() {
    trafficScheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(seconds: 30),
      name: 'check traffic',
      timeout: const Duration(seconds: 8),
      task: _trafficTask,
      minCycle: const Duration(seconds: 2),
    );

    // تسک 20 ثانیه‌ای حذف شد، چون منطق آن در تسک 1 دقیقه‌ای ادغام شد
    // statusScheduler = ...

    trafficScheduler?.start();
    // statusScheduler?.start();
    _isRunning = true;
    debugPrint("Background services started.");
  }

  // تسک بررسی ترافیک (هر 1 دقیقه)
  Future<void> _trafficTask() async {
      // await _userProvider?.getActiveSubAccount(isBackgroundCheck: true);
      await _userProvider?.initializeApp2(navigatorKey.currentContext!);

      if (_userProvider == null || _vpnProvider == null) {
      debugPrint("BackgroundService: Providers not ready.");
      return;
    }

    // فقط اگر کاربر آفلاین نباشد و وی‌پی‌ان متصل باشد
    if (await CheckInternetConnection.checkInternetConnection() == true &&
        _vpnProvider!.state == VpnConnectionState.connected) {
      if (_userProvider!.subModel == null) {
        debugPrint(
          "BackgroundService: User model is null, skipping traffic check.",
        );
        return;
      }

      // بررسی وضعیت اشتراک (که قبلاً لود شده)
      if (_userProvider!.accountStatus == AccountStatus.isTrafficEndOrIsExpired) {
        await _vpnProvider!.disconnect();
        return; // اگر اشتراک منقضی است، نیازی به بررسی ترافیک نیست
      }

      // محاسبه ترافیک مصرفی
      int trafficLimit =
          _userProvider!.subModel!.period.traffic * 1024 * 1024;

      // اگر ترافیک نامحدود است (مثلا 1000 گیگ)، بررسی نکن
      if (trafficLimit >= (10000 * 1024 * 1024)) {
        return;
      }

      int newDownload = _vpnProvider!.getCurrentTrafficUsage();
      int oldDownload = int.parse(_userProvider!.subModel!.download);
      int totalTrafficUsed = newDownload + oldDownload;

      await PrefHelpers.setTraffic(totalTrafficUsed.toString());

      // بررسی اتمام ترافیک
      if (totalTrafficUsed >= trafficLimit) {
        debugPrint("BackgroundService: Traffic limit reached, disconnecting.");

        await _vpnProvider!.disconnect();
      }
    }
  }

  void stopTasks() {
    trafficScheduler?.stop();
    // statusScheduler?.stop();
    _isRunning = false;
    debugPrint("Background services stopped.");
  }

  @override
  void dispose() {
    stopTasks();
    super.dispose();
  }
}
