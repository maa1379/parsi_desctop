import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// ایمپورت‌های خودتان را نگه دارید
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/core/utils.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../../core/PrefHelper/PrefHelpers.dart';
import '../../core/view_helper.dart';
import '../../provider/check_internet_connection.dart';
import '../../provider/v2ray_provider.dart';
import '../../provider/vpn_changer_state_service.dart';
import '../payment_screen.dart';
import '../profile_screen.dart';

class PowerBtnWidget extends StatefulWidget {
  const PowerBtnWidget({
    super.key,
    required this.enabled,
    required this.traffic,
    required this.vpnState,
  });

  final int traffic;
  final bool enabled;
  final VpnState vpnState;

  @override
  _PowerBtnWidgetState createState() => _PowerBtnWidgetState();
}

class _PowerBtnWidgetState extends State<PowerBtnWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _resizableController;

  Color getPulseColor(double value, bool isConnected) {
    if (isConnected) {
      return Color.lerp(Colors.green[100], Colors.green[900], value) ??
          Colors.green;
    } else {
      return Color.lerp(Colors.red[100], Colors.red[900], value) ?? Colors.red;
    }
  }

  @override
  void initState() {
    super.initState();
    _resizableController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _resizableController.dispose();
    super.dispose();
  }

  bool loading = true;
  Future<void> _handleTap() async {
    loading = false;
    setState(() {});
    final vpnProvider = context.read<VpnProvider>();
    if (vpnProvider.state == VpnConnectionState.connected) {
     await vpnProvider.disconnect();
      loading = true;
      setState(() {});
      return;
    }
    final String? serverConfig = await PrefHelpers.getServerConfig();
    if (serverConfig == null || serverConfig.isEmpty) {
      loading = true;
      setState(() {});
      if (mounted) {
        ViewHelper.showErrorDialog("لطفا ابتدا یک سرور انتخاب کنید", context);
      }
      return;
    }

    if (await CheckInternetConnection.checkInternetConnection() == false) {
      loading = true;
      setState(() {});
      if (mounted) {
        ViewHelper.showErrorDialog(
          "از اتصال خود به اینترنت اطمینان حاصل کنید",
          context,
        );
      }
      return;
    }
    await vpnProvider.connect();
    loading = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnProvider>(
      builder: (context, vpnProvider, child) {
        final bool isConnected =
            vpnProvider.state == VpnConnectionState.connected;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RepaintBoundary(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50, right: 15),
                child: AnimatedBuilder(
                  animation: _resizableController,
                  builder: (context, child) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: _handleTap,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff10172A),
                          border: Border.all(
                            color: getPulseColor(
                              _resizableController.value,
                              isConnected,
                            ),
                            width: 8,
                          ),
                        ),
                        child:
                            loading == false
                                ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(),
                                )
                                : const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.white,
                                  size: 30,
                                ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showBuyDialog(BuildContext context) {
    final accountStatus = context.read<UserProvider>().accountStatus;
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.sizeOf(context).height * .25,
            // کمی ارتفاع بیشتر
            width: MediaQuery.sizeOf(context).width * .9,
            decoration: BoxDecoration(
              color: const Color(0xff353A40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      accountStatus == AccountStatus.isTrafficEndOrIsExpired
                          ? "اعتبار زمانی یا حجمی شما به پایان رسیده است."
                          : (accountStatus == AccountStatus.none)
                          ? "شما اشتراک فعالی ندارید."
                          : "خطا در بررسی وضعیت اشتراک",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (accountStatus ==
                        AccountStatus.isTrafficEndOrIsExpired) {
                      context.to(const PaymentScreen());
                      // context.to(const ProfileScreen());
                    } else {
                      context.to(const PaymentScreen());
                    }
                  },
                  child:
                      Container(
                        height: 45,
                        width: MediaQuery.sizeOf(context).width * .5,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          accountStatus == AccountStatus.isTrafficEndOrIsExpired
                              ? "خرید اشتراک"
                              : "خرید اشتراک",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ).neuShadow,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
