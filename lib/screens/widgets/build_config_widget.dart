import 'dart:async';

import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/utils.dart';
import 'package:provider/provider.dart';

import '../../core/PrefHelper/PrefHelpers.dart';
import '../../generated/assets.dart';
import '../../models/configs_model.dart';
import '../../provider/server_provider.dart';
import '../../provider/v2ray_provider.dart';
import '../../provider/vpn_changer_state_service.dart';

class BuildConfigWidget {

  // --- ویجت دکمه اصلی در صفحه هوم (بدون تغییر زیاد، فقط استایل) ---
  Widget configWidget(Size size) {
    return Consumer<ServerProvider>(builder: (context, serverProvider, child) {
      if (serverProvider.firstTimeOfflineError) {
        return _buildErrorWidget(
            size, "لیست سرورها در حالت آفلاین در دسترس نیست");
      }
      if (!serverProvider.loading ||
          serverProvider.configsList.config.isEmpty) {
        return Container(
          height: size.height * .08,
          margin: const EdgeInsets.only(bottom: 15, left: 25, right: 25),
          alignment: Alignment.center,
          child: !serverProvider.loading
              ? const Text(
            "درحال دریافت سرور ها",
            style: TextStyle(color: Colors.grey),
          )
              : const CircularProgressIndicator(strokeWidth: 2),
        );
      }
      return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            serverProvider.initData();
            showModal(size, context);
          },
          child: Container(
            height: size.height * .08,
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: size.width * .05),
            margin: const EdgeInsets.only(bottom: 15, left: 25, right: 25),
            decoration: BoxDecoration(
              color: const Color(0xff27292D),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    AutoSizeText(
                      "انتخاب سرور",
                      minFontSize: 12,
                      maxFontSize: 18,
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                  ],
                ),
                const Gap(10),
                // بخش نمایش سرور فعال فعلی
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xff1E1F24),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<ServerProvider>(
                        builder: (context, provider, child) {
                          return FutureBuilder<dynamic>(
                              future: PrefHelpers.getActiveServer(),
                              builder: (context, snapShot) {
                                if (!snapShot.hasData) {
                                  return const Text("انتخاب کنید",
                                      style: TextStyle(color: Colors.grey, fontSize: 12));
                                }
                                return Text(
                                  "${snapShot.data}",
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                );
                              });
                        },
                      ),
                      const SizedBox(width: 8),
                      Consumer<ServerProvider>(
                        builder: (context, provider, child) {
                          return FutureBuilder<dynamic>(
                            future: PrefHelpers.getServerFlag(),
                            builder: (context, snapShot) {
                              if (!snapShot.hasData || snapShot.data == "") {
                                return const CircleAvatar(
                                    radius: 12, backgroundColor: Colors.grey);
                              }
                              return CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  snapShot.data,
                                  cacheManager: Utils.instance,
                                ),
                                radius: 12,
                                backgroundColor: Colors.transparent,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget(Size size, String message) {
    return Container(
      height: size.height * .08,
      width: size.width,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 30, left: 25, right: 25),
      decoration: BoxDecoration(
        color: const Color(0xff27292D),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }

  // --- نمایش Modal Bottom Sheet ---
  void showModal(Size size, BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: size.height * 0.85, // ارتفاع باتم شیت
          decoration: const BoxDecoration(
            color: Color(0xFF18191D), // رنگ پس زمینه اصلی
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: const ServerSelectionContent(),
        );
      },
    );
  }
}

// --- ویجت داخلی Modal (برای مدیریت State تب‌ها) ---
class ServerSelectionContent extends StatefulWidget {
  const ServerSelectionContent({super.key});

  @override
  State<ServerSelectionContent> createState() => _ServerSelectionContentState();
}

class _ServerSelectionContentState extends State<ServerSelectionContent> {
  // متغیر برای نگهداری تب انتخاب شده
  String selectedType = "v2ray";
  // نگهداری لینک سرور انتخاب شده برای تغییر بوردر
  String? currentActiveLink;

  @override
  void initState() {
    super.initState();
    _loadActiveServer();
  }

  void _loadActiveServer() async {
    // گرفتن لینک سرور فعال برای نمایش بوردر سبز
    String active = await PrefHelpers.getActiveServer();
    setState(() {
      currentActiveLink = active;
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final configs = serverProvider.configsList.config;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                Assets.imagesPers,
              ),
              opacity: 0.04,
              alignment: Alignment.bottomCenter,
              scale: 4,
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 20),
            // --- هدر (دکمه بازگشت و تایتل) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF26282E),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  const Text(
                    "انتخاب سرور",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
             Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTabItem("تروجان", "trojan"),
                      _buildTabItem("شادوساکس", "socks"),
                      _buildTabItem("اوتلاین", "outLine"),
                      _buildTabItem("v2ray", "v2ray"),
                    ],
                  ),
            const Divider(color: Colors.white10, thickness: 1, height: 20),

            // --- لیست سرورها ---
            Expanded(
              child: configs == null || configs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Directionality(
                textDirection: TextDirection.rtl, // لیست راست چین باشد
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: configs.where((e) => e.configType == selectedType).length,
                  itemBuilder: (context, index) {
                    final filteredList = configs.where((e) => e.configType == selectedType).toList();
                    final item = filteredList[index];
                    final bool isSelected = item.configLink == currentActiveLink;

                    return _buildServerCard(item, isSelected);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, String type) {
    final bool isActive = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20), // فاصله بین تب ها
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            border: isActive
                ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
                : null
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard(Config item, bool isSelected) {
    return GestureDetector(
      onTap: () async {
        // انتخاب شدن آیتم
        setState(() {
          currentActiveLink = item.configLink;
        });

        // لاجیک اتصال (از کد قبلی شما)
        final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
        final serverProvider = Provider.of<ServerProvider>(context, listen: false);

        bool isConnected = vpnProvider.state == VpnConnectionState.connected;
        if (isConnected) {
          await vpnProvider.disconnect();
          await Future.delayed(const Duration(milliseconds: 500));
        }
        //
        // if (selectedType == "wireGuard") {
        //   serverProvider.parseWireGuardServerConfig(
        //       item.configLink, item.serverName, item.serverFlagPath, item.serverIp, item.serverIp);
        //   vpnStateNotifier.value = VpnState.wireGuardState;
        // } else {
        //
        // }
        serverProvider.parseServerConfig(
            item.configLink, item.serverName, item.serverFlagPath, item.serverIp);
        vpnStateNotifier.value = VpnState.v2rayState;
       await vpnProvider.connect();
        // بستن مودال با کمی تاخیر برای دیدن افکت انتخاب
        Future.delayed(const Duration(milliseconds: 300), (){
          if(mounted) Navigator.pop(context);
        });
      },
      child: Container(
        height: 65,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF202125), // رنگ کارت تیره
          borderRadius: BorderRadius.circular(50), // گردی زیاد مشابه عکس
          border: isSelected
              ? Border.all(color: const Color(0xFF00C853), width: 1.5) // بوردر سبز اگر انتخاب شده
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // --- نام کشور و پرچم (سمت راست به خاطر RTL) ---
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                item.serverFlagPath,
                cacheManager: Utils.instance,
              ),
              onBackgroundImageError: (_, __) => const Icon(Icons.flag, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.serverName, // مثلا "Germany | آلمان"
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // --- دیوایدر عمودی ---
            Container(
              width: 1,
              height: 25,
              color: Colors.white12,
              margin: const EdgeInsets.symmetric(horizontal: 15),
            ),

            // --- پینگ (سمت چپ) ---
            // استفاده از FutureBuilder برای پینگ واقعی
            ServerPingBadge(configLink: item.configLink,serverIp: item.serverIp,),
          ],
        ),
      ),
    );
  }
}


// این کلاس را به انتهای فایل build_config_widget.dart اضافه کنید
class ServerPingBadge extends StatefulWidget {
  final String configLink;
  final String serverIp;

  const ServerPingBadge({super.key, required this.configLink, required this.serverIp});

  @override
  State<ServerPingBadge> createState() => _ServerPingBadgeState();
}

class _ServerPingBadgeState extends State<ServerPingBadge> {
  // متغیری برای نگهداری عملیات قابل کنسلی
  CancelableOperation<int?>? _pingOperation;

  int? _pingDelay;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPing();
  }

  void _fetchPing() {
    // دسترسی به پرووایدر (بدون listen)
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);

    // تبدیل Future معمولی به یک عملیات قابل کنسل شدن
    _pingOperation = CancelableOperation.fromFuture(
      vpnProvider.getPing(widget.configLink,widget.serverIp),
      onCancel: () => debugPrint('Ping canceled for ${widget.configLink.substring(0, 10)}...'),
    );

    // گوش دادن به نتیجه
    _pingOperation!.value.then((ping) {
      if (mounted) {
        setState(() {
          _pingDelay = ping;
          _loading = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _pingDelay = -1;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pingOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 90,
        child: Text(
          "Ping : ...",
          style: TextStyle(color: Colors.grey, fontSize: 11),
          textDirection: TextDirection.ltr,
        ),
      );
    }
    return SizedBox(
      width: 90,
      child: Text(
        (_pingDelay != null && _pingDelay! > 0)
            ? "Ping : $_pingDelay ms"
            : "Ping : Timeout",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}