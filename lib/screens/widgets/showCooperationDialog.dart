import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/PrefHelper/PrefHelpers.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/screens/payment_screen.dart';
import 'package:parsi/screens/profile_screen.dart';
import 'package:parsi/screens/support_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/view_helper.dart';
import '../../generated/assets.dart';
import '../../models/account_info_model.dart';
import '../../provider/splash_provider.dart';
import '../../provider/user_provider.dart';

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog(BuildContext context) {
  showDialog(
    context: context, barrierDismissible: true, // با کلیک بیرون دیالوگ بسته شود
    builder: (BuildContext ctx) {
      // استفاده از Directionality برای اطمینان از راست‌چین بودن متون فارسی
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent(),
      );
    },
  );
}

class _CooperationDialogContent extends StatelessWidget {
  const _CooperationDialogContent();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // رنگ سبز مورد استفاده در دکمه‌ها (مشابه تصویر)
    const greenColor = Color(0xFF1B5E20); // یا Color(0xFF2E7D32)
    final splashProvider = context.watch<SplashProvider>();
    final settings = splashProvider.settingModel?.last;
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // محتوای اصلی دیالوگ
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان
                    const Text(
                      "درخواست همکاری",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(30), // متن توضیحات
                    const Text(
                      "جهت همکاری در فروش در ربات تلگرام و اپلیکیشن پارسی، می توانید از طریق راه های ارتباطی زیر اقدام نمایید.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        // رنگ سفید کمی شفاف
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40), // دکمه پشتیبانی آنلاین
                    _buildActionButton(
                      text: "پشتیبانی آنلاین",
                      color: greenColor,
                      onTap: () {
                        launchUrl(Uri.parse(settings?.onlineSupportLink ?? ""),
                            mode: LaunchMode.inAppWebView);
                      },
                    ),
                    const Gap(15), // دکمه پشتیبانی تلگرام
                    _buildActionButton(
                      text: "پشتیبانی تلگرام",
                      color: greenColor,
                      onTap: () {
                        launchUrl(
                            Uri.parse(settings?.telegramSupportLink ?? ""),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ),
              // دکمه بستن (X) در بالا سمت چپ
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    Assets.imagesImg3,
                    height: 40,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog2(BuildContext context) {
  showDialog(
    context: context, barrierDismissible: true, // با کلیک بیرون دیالوگ بسته شود
    builder: (BuildContext ctx) {
      // استفاده از Directionality برای اطمینان از راست‌چین بودن متون فارسی
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent2(),
      );
    },
  );
}

class _CooperationDialogContent2 extends StatelessWidget {
  const _CooperationDialogContent2();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // رنگ سبز مورد استفاده در دکمه‌ها (مشابه تصویر)
    const greenColor = Color(0xFF1B5E20); // یا Color(0xFF2E7D32)
    final splashProvider = context.watch<SplashProvider>();
    final settings = splashProvider.settingModel?.last;
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // محتوای اصلی دیالوگ
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      "لینک دعوت",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30), // متن توضیحات
                    const Text(
                      "جهت همکاری در فروش در ربات تلگرام و اپلیکیشن پارسی، می توانید از طریق راه های ارتباطی زیر اقدام نمایید.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        // رنگ سفید
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40), // دکمه پشتیبانی آنلاین
                    _buildActionButton(
                      text: "پشتیبانی آنلاین",
                      color: greenColor,
                      onTap: () {
                        launchUrl(Uri.parse(settings?.onlineSupportLink ?? ""),
                            mode: LaunchMode.inAppWebView);
                      },
                    ),
                    const Gap(15), // دکمه پشتیبانی تلگرام
                    _buildActionButton(
                      text: "پشتیبانی تلگرام",
                      color: greenColor,
                      onTap: () {
                        launchUrl(
                            Uri.parse(settings?.telegramSupportLink ?? ""),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ),

              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    Assets.imagesImg3,
                    height: 40,
                  ),
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog3(BuildContext context) {
  showDialog(
    context: context, barrierDismissible: true, // با کلیک بیرون دیالوگ بسته شود
    builder: (BuildContext ctx) {
      // استفاده از Directionality برای اطمینان از راست‌چین بودن متون فارسی
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent3(),
      );
    },
  );
}

class _CooperationDialogContent3 extends StatelessWidget {
  const _CooperationDialogContent3();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // رنگ سبز مورد استفاده در دکمه‌ها (مشابه تصویر)
    const greenColor = Color(0xFF1B5E20); // یا Color(0xFF2E7D32)
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // محتوای اصلی دیالوگ
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      "خرید کانفیگ از ربات",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30), // متن توضیحات
                    const Text(
                      "در صورت لمس دکمه زیر وارد ربات تلگرام پارسی شده و می توانید کانفیگ v2ray خریداری کنید.توجه! اشتراک های خریداری شده از ربات تلگرام در این اپلیکیشن قابل استفاده نمی باشند و صرفا قابل استفاده در اپلیکیشن های V2ray می باشند",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40), // دکمه پشتیبانی آنلاین
                    _buildActionButton(
                      text: "خرید اشتراک از ربات",
                      color: greenColor,
                      onTap: () {
                        launchUrl(Uri.parse("https://t.me/parsi_vpnbot"),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                ),
              ),

              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    Assets.imagesImg3,
                    height: 40,
                  ),
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog4(BuildContext context) {
  showDialog(
    context: context, barrierDismissible: true, // با کلیک بیرون دیالوگ بسته شود
    builder: (BuildContext ctx) {
      // استفاده از Directionality برای اطمینان از راست‌چین بودن متون فارسی
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent4(),
      );
    },
  );
}

class _CooperationDialogContent4 extends StatelessWidget {
  const _CooperationDialogContent4();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // رنگ سبز مورد استفاده در دکمه‌ها (مشابه تصویر)
    const greenColor = Color(0xFF1B5E20); // یا Color(0xFF2E7D32)
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // محتوای اصلی دیالوگ
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      "ثبت کد اشتراک",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30),
                    // متن توضیحات
                    const Text(
                      "لطفا کد اشتراک خریداری شده از اپلیکیشن را اینجا وارد کنید تا اشتراک شما فعال شود.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(15),
                    const Text(
                      "توجه: \nبعد از فعالسازی، فقط شخصی که این اشتراک را خریداری کرده، امکان مدیریت اشتراک را دارد.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40),
                    // دکمه پشتیبانی آنلاین

                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * .8,
                      height: 45,
                      child: TextFormField(
                        controller:
                            Provider.of<UserProvider>(context, listen: false)
                                .subCode,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.green,
                            ),
                          ),
                          hintText: "کد اشتراک",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                    const Gap(25),
                    _buildActionButton(
                      text: "ثبت",
                      color: greenColor,
                      onTap: () {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        if (userProvider.subCode.text.isEmpty) {
                          ViewHelper.showErrorDialog(
                              "کد اشتراک را وارد کنید!", context);
                        } else {
                          // تابع checkSubNumber در UserProvider باقی مانده است
                          userProvider.checkSubNumber(
                              userProvider.subCode.text, true, context);
                        }
                      },
                    ),
                  ],
                ),
              ),

              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    Assets.imagesImg3,
                    height: 40,
                  ),
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// bool _hasShownServerStatusDialog = false;
//
// void showCooperationDialog5(BuildContext context, String subCode) {
//
//   // 2. چک کنید اگر قبلاً نمایش داده شده، تابع را متوقف کنید
//   if (_hasShownServerStatusDialog) return;
//
//   // 3. وضعیت را به true تغییر دهید تا دفعات بعد اجرا نشود
//   _hasShownServerStatusDialog = true;
//
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext ctx) {
//       return PopScope(
//         canPop: false,
//         child: Directionality(
//           textDirection: TextDirection.rtl,
//           child: CooperationDialogContent5(
//           ),
//         ),
//       );
//     },
//   ).then((_) {
//   });
// }

class CooperationDialogContent5 extends StatefulWidget {
  const CooperationDialogContent5({super.key});

  @override
  State<CooperationDialogContent5> createState() =>
      _CooperationDialogContent5State();
}

class _CooperationDialogContent5State extends State<CooperationDialogContent5> {
  String subCode = "";
  Sub? subModel;
  @override
  void initState() {
    Future.microtask(
      () async {
        subModel = await Sub.getDB();
        subCode = await PrefHelpers.getSubCode();
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // رنگ سبز مورد استفاده در دکمه‌ها (مشابه تصویر)
    const greenColor = Color(0xFF1B5E20); // یا Color(0xFF2E7D32)
    return Center(
      child: Container(
        width: size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    Assets.imagesEgel,
                    height: 100,
                    opacity: AlwaysStoppedAnimation(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 130),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      "اطلاعیه  اتمام حجم یا زمان",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30),
                    // متن توضیحات
                    Text(
                      (subModel?.period.isFree == true)
                          ? "اعتبار اشتراک نسخه ی رایگان و آزمایشی شما با کد اشتراک $subCode  به اتمام رسیده است. لطفا از دکمه ی زیر، اقدام به خرید اشتراک نمایید."
                          : "کاربر گرامی!\nاشتراک $subCode بدلیل اتمام حجم / زمان سرویس غیر فعال شده است. جهت فعالسازی و استفاده از امکانات اپلیکیشن میبایست اشتراک را خریداری نمایید.",
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40),
                    // دکمه پشتیبانی آنلاین
                    _buildActionButton(
                      text: (subModel?.period.isFree == true)
                          ? "خرید و فعالسازی اشتراک"
                          : "خرید و فعالسازی اشتراک",
                          // : "تمدید و فعالسازی اشتراک",
                      color: greenColor,
                      onTap: () {
                        context.pop();
                        if ((subModel?.period.isFree == true)) {
                          context.to(PaymentScreen());
                        } else {
                          // context.to(ProfileScreen());
                          context.to(PaymentScreen());
                        }
                      },
                    ),
                    Gap(10),
                    _buildActionButton(
                      text: "مدیریت اشتراک ها",
                      color: greenColor,
                      onTap: () {
                        context.to(ProfileScreen());
                      },
                    ),
                    Gap(10),
                    _buildActionButton(
                      text: "ثبت کد اشتراک",
                      color: greenColor,
                      onTap: () {
                        showCooperationDialog4(context);
                      },
                    ),
                    Gap(10),
                    _buildActionButton(
                      text: "ارتباط با پشتیبانی",
                      color: greenColor,
                      onTap: () {
                        context.to(SupportScreen());
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
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog6(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent6(),
      );
    },
  );
}

class _CooperationDialogContent6 extends StatelessWidget {
  const _CooperationDialogContent6();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    Assets.imagesJam,
                    height: 120,
                    opacity: AlwaysStoppedAnimation(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 130),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      " با تشکر از پرداخت شما",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30), // متن توضیحات
                    Text(
                      "فیش واریزی با موفقیت ارسال شد. پس از تایید توسط ادمین اشتراک شما فعال شده و از طریق پیامک و اعلانات اطلاع رسانی می شود.زمان تقریبی برای تایید فیش واریزی 1 تا 15 دقیقه می باشد",
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// تابع اصلی برای نمایش دیالوگ
void showCooperationDialog7(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext ctx) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _CooperationDialogContent7(),
      );
    },
  );
}

class _CooperationDialogContent7 extends StatelessWidget {
  const _CooperationDialogContent7();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: size.width * 0.85,
        // عرض دیالوگ ۸۵ درصد صفحه
        constraints: const BoxConstraints(maxWidth: 400),
        // حداکثر عرض
        decoration: BoxDecoration(
          // گرادینت تیره پس‌زمینه
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C313C), // رنگ کمی روشن‌تر در بالا سمت چپ
              Color(0xFF0D0E11), // رنگ تیره‌تر در پایین سمت راست
            ],
          ),
          borderRadius: BorderRadius.circular(35), // گوشه‌های گرد
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    Assets.imagesJam,
                    height: 120,
                    opacity: AlwaysStoppedAnimation(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 130),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ارتفاع به اندازه محتوا
                  children: [
                    // عنوان "درخواست همکاری"
                    const Text(
                      "وضعیت سرور",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ]),
                    ),
                    const Gap(30), // متن توضیحات
                    Text(
                      context
                              .watch<SplashProvider>()
                              .settingModel
                              ?.last
                              .aboutServers ??
                          "اطلاعاتی یافت نشد",
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: _buildCloseButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت سازنده دکمه بستن (X)
  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF26282E),
          // رنگ پس‌زمینه دکمه
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05), // درخشش ملایم دور دکمه
              blurRadius: 10, spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white54, size: 24),
      ),
    );
  }

  // ویجت سازنده دکمه‌های عملیاتی (سبز رنگ)
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      // تمام عرض
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          // رنگ متن
          side: BorderSide(color: color, width: 1.5),
          // رنگ و ضخامت حاشیه سبز
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor:
              Colors.black.withOpacity(0.2), // پس‌زمینه کمی تیره داخل دکمه
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
