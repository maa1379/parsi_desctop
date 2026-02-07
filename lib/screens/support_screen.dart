import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/provider/splash_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/assets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final splashProvider = context.watch<SplashProvider>();
    final settings = splashProvider.settingModel?.last;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF18191D), // رنگ پس‌زمینه اصلی
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 100),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      Assets.imagesAzadi,
                    ),
                    opacity: 0.04,
                    alignment: Alignment.bottomCenter,
                    scale: 3,
                  ),
                ),
              ),
               Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Image.asset(
                        Assets.imagesLogo2,
                        height: 30,
                      ),
                      // آیکون لوگوی کوچک پایین
                      Text("پارسی",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  )),
              Column(
                children: [
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF26282E),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 18, color: Colors.grey),
                          ),
                        ),
                        const Text(
                          "پشتیبانی",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 45),
                        // برای وسط‌چین ماندن متن
                      ],
                    ),
                  ),

                  const Gap(30),

                  // --- متن توضیحی ---
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "از طریق راههای زیر میتوانید با تیم ما ارتباط برقرار کنید.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Gap(30),

                  // --- شبکه گزینه‌ها (Grid) ---
                  if (splashProvider.firstTimeOfflineError)
                    _buildOfflineError()
                  else if (settings == null)
                    const Expanded(
                        child: Center(
                            child: Text("اطلاعات پشتیبانی در دسترس نیست",
                                style: TextStyle(color: Colors.grey))))
                  else
                    Expanded(
                        child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGridItem(
                              title: "پشتیبانی آنلاین",
                              iconAsset: Assets.imagesHelpDesk,
                              url: settings.onlineSupportLink,
                              iconColor: Colors.green, // رنگ آیکون مشابه عکس
                            ),
                            _buildGridItem(
                              title: "پشتیبانی تلگرام",
                              iconAsset: Assets.imagesTelegram,
                              url: settings.telegramSupportLink,
                              iconColor: Colors.blue,
                            ),
                          ],
                        ),
                        Gap(15),
                        Divider(
                          color: Colors.blueAccent.withOpacity(0.5),
                          indent: 80,
                          endIndent: 80,
                        ),
                        Gap(15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGridItem(
                              title: "اینستاگرام",
                              iconAsset: Assets.imagesInstagram,
                              url: settings.instagramLink,
                              iconColor: Colors.purpleAccent,
                            ),
                            _buildGridItem(
                              title: "کانال تلگرام",
                              iconAsset: Assets.imagesTelegram,
                              url: settings.telegramLink,
                              iconColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                        Gap(15),
                        Divider(
                          color: Colors.blueAccent.withOpacity(0.5),
                          indent: 80,
                          endIndent: 80,
                        ),
                        Gap(15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGridItem(
                              title: "واتس اپ",
                              iconAsset: Assets.imagesWhats,
                              url: settings.whatsAppLink,
                              iconColor: Colors.redAccent,
                            ),
                            _buildGridItem(
                              title: "گروه تلگرام",
                              iconAsset: Assets.imagesTelegram,
                              url: settings.telegramGroupLink,
                              iconColor: Colors.lightBlue,
                            ),
                          ],
                        ),
                        Gap(15),
                      ],
                    )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String title,
    required String iconAsset,
    required String? url,
    required Color iconColor,
  }) {

    if (url == null || url.isEmpty) {
      return const SizedBox(
        width: 35,
        height: 35,
      );
    }

    return InkWell(
      onTap: () {
        if (title == "پشتیبانی آنلاین") {
          launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
        } else {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // آیکون رنگی
          Image.asset(
            iconAsset,
            width: 35,
            height: 35,
          ),
          const Gap(15),
          AutoSizeText(
            title,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineError() {
    return const Expanded(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            "برای مشاهده اطلاعات پشتیبانی،\nلطفا بار اول به اینترنت متصل شوید.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
