import 'dart:async';
import 'dart:io'; // اضافه شده برای چک کردن پلتفرم
import 'package:flutter/material.dart';
import 'package:flutter_v2ray_client_desktop/flutter_v2ray_client_desktop.dart' as desktop;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:parsi/provider/vpn_changer_state_service.dart';

import '../core/PrefHelper/PrefHelpers.dart';
import '../core/network/api_service.dart';
import 'utils.dart';

enum VpnConnectionState { disconnected, connected, disconnecting, error }

class VpnSpeedData {
  String upload;
  final String uploadT;
  String download;
  final String downloadT;
  String duration;

  VpnSpeedData({
    required this.upload,
    required this.download,
    required this.duration,
    required this.uploadT,
    required this.downloadT,
  });

  factory VpnSpeedData.zero() {
    return VpnSpeedData(
      upload: "0",
      download: "0",
      duration: "00:00:00",
      uploadT: "0",
      downloadT: "0",
    );
  }
}

class VpnProvider extends ChangeNotifier {
  late final desktop.FlutterV2rayClientDesktop _desktopV2ray;

  VpnConnectionState _state = VpnConnectionState.disconnected;
  VpnConnectionState get state => _state;

  final _speedStreamController = StreamController<VpnSpeedData>.broadcast();
  Stream<VpnSpeedData> get speedStream => _speedStreamController.stream;

  desktop.V2rayStatus _v2rayStatusDesktop = const desktop.V2rayStatus();

  VpnState _vpnType = vpnStateNotifier.value;
  VpnState get vpnType => _vpnType;

  // --- تغییرات جدید: متغیرهای نوع اتصال و پسورد ---
  desktop.ConnectionType _connectionType = desktop.ConnectionType.systemProxy;
  desktop.ConnectionType get connectionType => _connectionType;

  String? _sudoPassword;
  bool get hasSudoPassword => _sudoPassword != null && _sudoPassword!.isNotEmpty;
  // ----------------------------------------------

  bool _isPinging = false;
  bool showPing = false;
  String ping = "0";
  bool hasInterNet = true;

  AnimationController? animationController;

  VpnProvider() {
    _desktopV2ray = desktop.FlutterV2rayClientDesktop(
      statusListener: _onDesktopStatusChanged, logListener: (String log) {
      debugPrint(log); // برای دیباگ بهتر
    },
    );
    _initialize();
  }

  Future<void> _initialize() async {
    vpnStateNotifier.addListener(_onVpnTypeChanged);
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      hasInterNet = (status == InternetStatus.connected);
      notifyListeners();
    });

    // لود کردن تنظیمات پیش‌فرض (اختیاری)
    // مثلا می‌توانید آخرین حالت انتخاب شده را از PrefHelpers بخوانید
  }

  // --- تغییرات جدید: متد تغییر حالت اتصال ---
  void setConnectionType(desktop.ConnectionType type) {
    _connectionType = type;
    notifyListeners();
  }

  // --- تغییرات جدید: ذخیره پسورد ---
  void setSudoPassword(String password) {
    _sudoPassword = password;
    notifyListeners();
  }
  // ---------------------------------------

  void _onDesktopStatusChanged(desktop.V2rayStatus status) {
    _v2rayStatusDesktop = status;
    final speedData = VpnSpeedData(
      upload: !hasInterNet ? "0" : status.upload.toString(),
      download: !hasInterNet ? "0" : status.download.toString(),
      duration: _formatDurationDesktop(status.duration),
      downloadT: status.totalDownload.toString(),
      uploadT: status.totalUpload.toString(),
    );
    _processStatusUpdate(status.state == desktop.ConnectionState.connected, speedData);
  }

  void _processStatusUpdate(bool isConnected, VpnSpeedData speedData) async {
    _speedStreamController.add(speedData);
    VpnConnectionState newState = isConnected ? VpnConnectionState.connected : VpnConnectionState.disconnected;

    if (isConnected) {
      lastKnownData = speedData;
    } else if (_state == VpnConnectionState.connected) {
      updateTrafficAccount(getCurrentTrafficUsage());
      lastKnownData = VpnSpeedData.zero();
      _speedStreamController.add(lastKnownData);
    }

    if (_state != newState) {
      _updateState(newState);
      if (newState == VpnConnectionState.connected) {
        await Future.delayed(const Duration(seconds: 2));
        updatePing();
      }
    }
  }

  // --- تغییرات جدید: متد اتصال آپدیت شده ---
  Future<void> connect() async {
    final conf = await PrefHelpers.getServerConfig();
    if (conf == null) return;

    // بررسی نیاز به پسورد در مک و لینوکس برای حالت VPN
    if (_connectionType == desktop.ConnectionType.vpn &&
        (Platform.isMacOS || Platform.isLinux)) {
      if (_sudoPassword == null || _sudoPassword!.isEmpty) {
        // اگر پسورد ست نشده بود، ارور برمی‌گرداند یا لاگ می‌اندازد
        // هندل کردن پرامپت باید در UI قبل از زدن دکمه اتصال انجام شده باشد
        debugPrint("Error: Sudo password is required for VPN mode");
        return;
      }
    }

    try {
      await _desktopV2ray.startV2Ray(
        config: conf,
        // اگر سیستم پروکسی باشد، پسورد نال ارسال می‌شود که مشکلی ندارد
        sudoPassword: _connectionType == desktop.ConnectionType.vpn ? _sudoPassword : null,
        connectionType: _connectionType,
      );
    } catch (e) {
      debugPrint("Connection Error: $e");
      _updateState(VpnConnectionState.disconnected);
    }
  }

  Future<void> disconnect() async {
    await _desktopV2ray.stopV2Ray();
  }

  String _formatDurationDesktop(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '00:$mm:$ss';
  }

  void _updateState(VpnConnectionState newState) {
    if (_state == newState) return;
    _state = newState;
    if (newState == VpnConnectionState.connected) {
      animationController?.forward();
    } else {
      animationController?.reverse();
      ping = "0";
      showPing = false;
    }
    notifyListeners();
  }

  VpnSpeedData lastKnownData = VpnSpeedData.zero();
  void _onVpnTypeChanged() {
    _vpnType = vpnStateNotifier.value;
    notifyListeners();
  }

  Future<void> updatePing() async {
    if (_isPinging || _state != VpnConnectionState.connected) return;
    _isPinging = true;
    showPing = true;
    notifyListeners();
    try {
      int pingTime = 0;
      pingTime = await _desktopV2ray.getServerDelay(url: await PrefHelpers.getServerConfigUri(),type: desktop.DelayType.tcp);
      ping = pingTime <= 0 ? "عدم دریافت پینگ" : "$pingTime پینگ سرور: ";
    } catch (_) {
      ping = "خطا";
    } finally {
      showPing = false;
      _isPinging = false;
      notifyListeners();
    }
  }

  Future<int> getPing(url , ip)async{
    return await _desktopV2ray.getServerDelay(url: url);
  }

  int getCurrentTrafficUsage() => getCombinedTraffic(lastKnownData.downloadT, lastKnownData.uploadT);

  Future<void> updateTrafficAccount(int traffic) async {
    try {
      final res = await ApiService().updateTrafficAccount(await PrefHelpers.getSubCode(), traffic);
      await PrefHelpers.setTraffic(traffic.toString());
      if (res.statusCode == 200) {
        await PrefHelpers.removeTraffic();
      }
    } catch (e) {
      debugPrint("Error updateTrafficAccount: $e");
    }
  }

  @override
  void dispose() {
    _speedStreamController.close();
    vpnStateNotifier.removeListener(_onVpnTypeChanged);
    super.dispose();
  }
}