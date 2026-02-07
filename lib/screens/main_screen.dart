import 'dart:async';
import 'dart:io'; // برای تشخیص پلتفرم
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/PrefHelper/PrefHelpers.dart';
import 'package:parsi/provider/pop_up_provider.dart';
import 'package:parsi/provider/server_provider.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:parsi/screens/support_screen.dart';
import 'package:parsi/screens/traning_screen.dart';
import 'package:parsi/screens/wallet_screen.dart';
import 'package:parsi/screens/widgets/connection_btn.dart';
import 'package:parsi/screens/widgets/showCooperationDialog.dart';
import 'package:parsi/screens/widgets/show_ping_widget.dart';
import 'package:parsi/screens/widgets/speed_test/speed_test_screen.dart';
import 'package:parsi/screens/widgets/vpn_speed_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// اضافه کردن پکیج دسکتاپ برای دسترسی به Enum ها
import 'package:flutter_v2ray_client_desktop/flutter_v2ray_client_desktop.dart' as desktop;

import '../core/nav_helper.dart';
import '../core/utils.dart';
import '../generated/assets.dart';
import '../provider/baclground_service_Provider.dart';
import '../provider/notification_provider.dart';
import '../provider/splash_provider.dart';
import '../provider/v2ray_provider.dart';
import '../provider/vpn_changer_state_service.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final Size size = MediaQuery.sizeOf(context);
  late final UserProvider _userProvider;
  late final VpnProvider _vpnProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getData();
  }

  void getData() async {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _vpnProvider = context.read<VpnProvider>();
    _vpnProvider.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );
    await _userProvider.initializeApp(context);
    Provider.of<PopUpProvider>(context, listen: false).getPopUp(() async {
      await Future.delayed(const Duration(seconds: 2));
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => Provider.of<PopUpProvider>(
          context,
          listen: false,
        ).showInitDialog(context),
      );
    });

    await Provider.of<ServerProvider>(context, listen: false).initData();
    Provider.of<NotificationProvider>(context, listen: false).initData();
    final background = Provider.of<BackgroundServiceProvider>(
      context,
      listen: false,
    );
    background.updateDependencies(_userProvider, _vpnProvider);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vpnProvider.animationController?.dispose();
    _userProvider.disposed();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _userProvider.getActiveSubAccount();
      final background = Provider.of<BackgroundServiceProvider>(
        context,
        listen: false,
      );
      background.updateDependencies(_userProvider, _vpnProvider);
    }
  }

  // --- ویجت دیالوگ پسورد سودو ---
  Future<void> _promptForSudoPassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: const Color(0xFF2A2D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.security, color: Colors.amber),
                  SizedBox(width: 10),
                  Text('مجوز دسترسی سیستمی', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'برای استفاده از حالت TUN/VPN در ${Platform.isMacOS ? 'مک' : 'لینوکس'}، نیاز به دسترسی ادمین (Sudo) است.\nلطفا رمز سیستم خود را وارد کنید.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      labelText: 'رمز سیستم (Password)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // اگر کنسل کرد، برمی‌گردیم به حالت پروکسی
                    context.read<VpnProvider>().setConnectionType(desktop.ConnectionType.systemProxy);
                    Navigator.of(context).pop();
                  },
                  child: const Text('انصراف', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  child: const Text('تایید'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      context.read<VpnProvider>().setSudoPassword(result);
    }
  }

  // --- ویجت سوییچ بین VPN و Proxy ---
  Widget _buildConnectionModeSwitch() {
    return Consumer<VpnProvider>(
      builder: (context, vpnProvider, child) {
        // مخفی کردن سوییچ وقتی متصل هستیم
        if (vpnProvider.state == VpnConnectionState.connected ||
            vpnProvider.state == VpnConnectionState.disconnecting) {
          return const SizedBox.shrink();
        }

        final isVpn = vpnProvider.connectionType == desktop.ConnectionType.vpn;

        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // دکمه پروکسی
              GestureDetector(
                onTap: () => vpnProvider.setConnectionType(desktop.ConnectionType.systemProxy),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isVpn ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, size: 16, color: !isVpn ? Colors.blueAccent : Colors.grey),
                      const SizedBox(width: 6),
                      Text("Proxy", style: TextStyle(
                          color: !isVpn ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: !isVpn ? FontWeight.bold : FontWeight.normal
                      )),
                    ],
                  ),
                ),
              ),
              // دکمه VPN
              GestureDetector(
                onTap: () async {
                  vpnProvider.setConnectionType(desktop.ConnectionType.vpn);
                  // اگر مک یا لینوکس بود و پسورد نداشت، بپرس
                  if ((Platform.isMacOS || Platform.isLinux) && !vpnProvider.hasSudoPassword) {
                    await _promptForSudoPassword();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isVpn ? Colors.amber.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: isVpn ? Colors.amber : Colors.grey),
                      const SizedBox(width: 6),
                      Text("VPN (Tun)", style: TextStyle(
                          color: isVpn ? Colors.amber : Colors.grey,
                          fontSize: 12,
                          fontWeight: isVpn ? FontWeight.bold : FontWeight.normal
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionBlockingWidget(AccountStatus status) {
    context.read<VpnProvider>().disconnect();
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.7),
        alignment: Alignment.center,
        child: CooperationDialogContent5(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userLoading = userProvider.initialUserLoading;
    final accountStatus = userProvider.accountStatus;

    final bool firstTimeOfflineError = userProvider.firstTimeOfflineError ||
        context.watch<ServerProvider>().firstTimeOfflineError ||
        context.watch<SplashProvider>().firstTimeOfflineError ||
        context.watch<NotificationProvider>().firstTimeOfflineError;

    final bool showBlockingDialog = userLoading &&
        !firstTimeOfflineError &&
        (accountStatus == AccountStatus.isTrafficEndOrIsExpired ||
            (accountStatus == AccountStatus.none &&
                userProvider.errorMessage == null));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        drawer: const CustomRightDrawer(),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            color: Colors.black,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff2A2D32), Color(0xff2A2D32), Color(0xff131313)],
            ),
          ),
          child: (!userLoading && !firstTimeOfflineError)
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () async {
              context.read<UserProvider>().initializeApp(context);
              context.read<ServerProvider>().initData();
              context.read<NotificationProvider>().initData();
            },
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.imagesDarkBg),
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, right: 20), // Padding اصلاح شده
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // هدر بالا
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const AutoSizeText(
                              "پارسی",
                              maxFontSize: 40,
                              minFontSize: 30,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(5),
                            Image.asset(Assets.imagesParsilogowite),
                          ],
                        ),
                        const Gap(5),
                        const VpnSpeedWidget(),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        Assets.imagesImg2,
                        fit: BoxFit.cover,
                      )),
                  _buildPowerBtn(),
                  _buildSubInfoWidget(),
                  HomeScreen(widget:   _buildConnectionModeSwitch(),),
                  ShowPingWidget(),
                  // دکمه‌های منو و نوتیفیکیشن
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState!.openDrawer();
                              },
                              icon: const Icon(
                                Icons.menu,
                                size: 30,
                              ),
                            ),
                            Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                return IconButton(
                                  onPressed: () {
                                    context
                                        .to(const NotificationScreen());
                                  },
                                  icon: badge.Badge(
                                    badgeContent: Text(
                                        provider.unreadCount.toString()),
                                    position:
                                    badge.BadgePosition.topStart(),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18,
                                      child: Center(
                                        child: Icon(
                                          Icons.notifications_none,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showBlockingDialog)
                    _buildSubscriptionBlockingWidget(accountStatus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (بقیه ویجت‌ها: _buildPowerBtn, _buildSubInfoWidget مثل قبل) ...
  Widget _buildPowerBtn() {
    return ValueListenableBuilder<VpnState>(
      valueListenable: vpnStateNotifier,
      builder: (context, vpnState, child) {
        final vpnProvider = context.watch<VpnProvider>();
        final bool isConnected =
            vpnProvider.state == VpnConnectionState.connected;

        final int currentTraffic = vpnProvider.getCurrentTrafficUsage();
        return PowerBtnWidget(
          enabled: isConnected,
          traffic: currentTraffic,
          vpnState: vpnState,
        );
      },
    );
  }

  Widget _buildSubInfoWidget() {
    // (کد قبلی بدون تغییر)
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.initialUserLoading || userProvider.subModel == null) {
          return const SizedBox.shrink();
        }
        return Positioned(
          bottom: 90,
          left: 20,
          right: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const AutoSizeText(
                      "حجم باقیمانده",
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: TextStyle(color: Colors.red),
                    ),
                    const Gap(10),
                    AutoSizeText(
                      (int.tryParse(userProvider.subModel!.traffic) ?? 0) >= 10000000000
                          ? "نامحدود"
                          : userProvider.calculateTraffic(),
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Gap(10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const AutoSizeText(
                      "کد اشتراک",
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: TextStyle(color: Colors.red),
                    ),
                    const Gap(10),
                    AutoSizeText(
                      userProvider.subModel!.subCode,
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Gap(10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const AutoSizeText(
                      "زمان باقیمانده",
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: TextStyle(color: Colors.red),
                    ),
                    const Gap(10),
                    AutoSizeText(
                      Utils.checkDate(userProvider.subModel!.subDay),
                      minFontSize: 8,
                      maxFontSize: 14,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ... (کلاس CustomRightDrawer و extension بدون تغییر) ...
class CustomRightDrawer extends StatelessWidget {
  const CustomRightDrawer({super.key});
  // ... (کد قبلی دراور)
  @override
  Widget build(BuildContext context) {
    // رنگ‌های استخراج شده از تصویر
    final userProvider = context.watch<UserProvider>();
    const Color cardColor = Color(0xFF26282E);
    const Color highlightColor = Color(0xFFCC3333); // رنگ قرمز
    const Color goldColor = Color(0xFFFFD700);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      // عرض منو
      backgroundColor: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl, // راست‌چین کردن کل منو
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "کد اشتراک",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, size: 12, color: goldColor),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "VIP",
                                    style: TextStyle(
                                        color: goldColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder(
                            future: PrefHelpers.getSubCode(),
                            builder: (context, asyncSnapshot) {
                              return Text(
                                "ID: ${asyncSnapshot.data}",
                                style:
                                TextStyle(color: Colors.grey, fontSize: 12),
                              );
                            }),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  context.to(const WalletScreen());
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: highlightColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.wallet, color: highlightColor, size: 20),
                          SizedBox(width: 8),
                          Text("کیف پول :",
                              style: TextStyle(color: highlightColor)),
                        ],
                      ),
                      Text(
                          "${(userProvider.walletModel?.balance ?? "0").toPrice()} تومان",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildMenuItem(
                      "ثبت کد اشتراک",
                      Icons.qr_code_scanner,
                      highlightColor,
                          () {
                        Provider.of<UserProvider>(context, listen: false)
                            .subCode
                            .clear();
                        showCooperationDialog4(context);
                      },
                    ),
                    _buildMenuItem(
                      "آموزش استفاده",
                      Icons.play_circle_outline,
                      highlightColor,
                          () {
                        context.to(TrainingScreen());
                      },
                    ),
                    _buildMenuItem("خرید از طریق ربات",
                        Icons.shopping_cart_outlined, highlightColor, () {
                          showCooperationDialog3(context);
                        }, isBold: true, isAssets: true, assets: Assets.imagesV),
                    _buildMenuItem(
                      "پنل همکاری",
                      Icons.storefront,
                      highlightColor,
                          () {
                        showCooperationDialog(context);
                      },
                    ),
                    _buildMenuItem(
                      "وبسایت پارسی",
                      Icons.language,
                      highlightColor,
                          () {
                        launchUrl(Uri.parse("https://parsi1.sbs/"),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                    _buildMenuItem(
                      "لینک دعوت",
                      Icons.share,
                      highlightColor,
                          () {
                        showCooperationDialog2(context);
                      },
                    ),
                    _buildMenuItem(
                      "سوالات متداول",
                      Icons.help_outline,
                      highlightColor,
                          () {
                        context.to(FAQScreen());
                      },
                    ),
                    _buildMenuItem(
                      "تست سرعت",
                      Icons.headset_mic,
                      highlightColor,
                          () {
                        context.to(SpeedTestScreen());
                      },
                    ),
                    _buildMenuItem(
                      "پشتیبانی",
                      Icons.headset_mic,
                      highlightColor,
                          () {
                        context.to(SupportScreen());
                      },
                    ),
                    // _buildMenuItem(
                    //   "قوانین و مقررات",
                    //   Icons.privacy_tip_outlined,
                    //   highlightColor,
                    //   () {
                    //     context.to(SupportScreen());
                    //   },
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده آیتم‌های منو
  Widget _buildMenuItem(
      String title, IconData icon, Color accentColor, Function() onTap,
      {bool isBold = false, bool isAssets = false, String? assets}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF26282E), // رنگ پس‌زمینه دکمه
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: isAssets
            ? Image.asset(
          assets ?? "",
          height: 16,
          color: accentColor,
        )
            : Icon(icon, color: accentColor),
        // آیکون سمت راست (چون RTL است)
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined,
            size: 14, color: Colors.grey),
        // فلش کوچک سمت چپ
        onTap: onTap,
      ),
    );
  }
}

extension on Object {
  String toPrice() {
    String numberString = toString();
    if (numberString == "null") return "0";
    final numberDigits = List.from(numberString.split(''));
    int index = numberDigits.length - 3;
    while (index > 0) {
      numberDigits.insert(index, ',');
      index -= 3;
    }
    return numberDigits.join();
  }
}