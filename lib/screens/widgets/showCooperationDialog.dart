import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/PrefHelper/PrefHelpers.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/core/number_formatters.dart';
import 'package:parsi/screens/payment_screen.dart';
import 'package:parsi/screens/profile_screen.dart';
import 'package:parsi/screens/support_screen.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/view_helper.dart';
import '../../generated/assets.dart';
import '../../models/account_info_model.dart';
import '../../provider/checkOutUtil.dart';
import '../../provider/splash_provider.dart';
import '../../provider/user_provider.dart';
import '../faq_screen.dart';
import '../traning_screen.dart';
import '../wallet_screen.dart';

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
                      "اپلیکیشن نسخه همکاری",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(30), // متن توضیحات
                    const Text(
                      "در این نسخه ، گزینه خرید اشتراک، پشتیبانی و چت روم وجود ندارد.اپلیکیشن نسخه همکاری را برای دوستان و مشتریان خود ارسال کنید و کد اشتراک خریداری شده از همین اپلیکیشن را با قیمت دلخواه خودتان، به آنها بفروشید.خرید، تمدید و پشتیبانی اشتراک کاربرهایتان با خودتان است.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white70,
                        // رنگ سفید کمی شفاف
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Text(
                      "مهم: کاربرها در این نسخه امکان خرید و تمدید اشتراک را ندارند و صرفا از شما باید کد اشتراک را خریداری کنند.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white70,
                        // رنگ سفید کمی شفاف
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Text(
                      "توجه: سرورها در هر دو اپلیکیشن نسخه اصلی و همکاری کاملا یکسان است",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white70,
                        // رنگ سفید کمی شفاف
                        fontSize: 15,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40), // دکمه پشتیبانی آنلاین
                    _buildActionButton(
                      text: "دانلود اپلیکیشن نسخه همکاری",
                      color: greenColor,
                      onTap: () {
                        launchUrl(Uri.parse(settings?.hamkarLink ?? ""),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                    const Gap(15),
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
                          hintText:"کد اشتراک",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14)
                        ),
                      ),
                    ),
                    const Gap(25),
                    _buildActionButton(
                      text: "ثبت",
                      color: greenColor,
                      onTap: () async{
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        if (userProvider.subCode.text.isEmpty) {
                          ViewHelper.showErrorDialog(
                              "کد اشتراک را وارد کنید!", context);
                        } else {
                          // تابع checkSubNumber در UserProvider باقی مانده است
                         await userProvider.checkSubNumber(
                              userProvider.subCode.text, true, context);
                         userProvider.initializeApp2(context);
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

class CooperationDialogContent5 extends StatefulWidget {
  const CooperationDialogContent5({super.key});

  @override
  State<CooperationDialogContent5> createState() =>
      _CooperationDialogContent5State();
}

class _CooperationDialogContent5State extends State<CooperationDialogContent5> {
  String subCode = "";
  Sub? subModel;

  String expireDateStr = "";
  String expireTimeStr = "";

  @override
  void initState() {
    Future.microtask(
          () async {
        subModel = await Sub.getDB();
        subCode = await PrefHelpers.getSubCode();

        if (subModel != null) {
          // استفاده از toLocal برای حل مشکل تفاوت ساعت با سرور (UTC)
          DateTime expireDateTime = subModel!.subDay.toLocal();

          expireTimeStr =
          "${expireDateTime.hour.toString().padLeft(2, '0')}:${expireDateTime.minute.toString().padLeft(2, '0')}";
          expireDateStr = expireDateTime.toPersianDate();
        }

        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const greenColor = Color(0xFF1B5E20);

    return Center(
      child: Container(
        width: size.width * 0.90,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C313C), Color(0xFF0D0E11)],
          ),
          borderRadius: BorderRadius.circular(35),
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
                    'assets/images/egel.png',
                    height: 100,
                    opacity: const AlwaysStoppedAnimation(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "اطلاعیه اتمام زمان استفاده از اشتراک",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 3.0,
                                color: Colors.black45),
                          ]),
                    ),
                    const Gap(25),
                    RichText(
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.8,
                            fontFamily: 'Vazir'), // در صورت نیاز به فونت پیش‌فرض، آن را حذف کنید
                        children: [
                          const TextSpan(text: "کاربر گرامی،\nاشتراک شما ("),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: subCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("کد اشتراک کپی شد"),
                                      backgroundColor: Colors.green),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Gap(4),
                                  Text(subCode,
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const Gap(4),
                                  const Icon(Icons.copy,
                                      color: Colors.red, size: 14),
                                  const Gap(4),
                                ],
                              ),
                            ),
                          ),
                          TextSpan(
                              text:
                              ") به علت رسیدن به پایان مدت زمان اشتراک، در تاریخ $expireDateStr و ساعت ( $expireTimeStr )، منقضی شده است.\nلطفاً جهت تمدید همین اشتراک با همین پلن، گزینه \"تمدید همین اشترا‌ک\" را انتخاب نمایید. در صورتی که قصد خرید پلن های دیگری را دارید، گزینه \"خرید اشتراک جدید\" را انتخاب کنید.\nهمچنین، در صورتی که از قبل اشتراک فعال دیگری دارید، می‌توانید از بخش \"مدیریت اشتراک ها\" اقدام به فعال‌سازی آن نمایید."),
                        ],
                      ),
                    ),
                    const Gap(30),
                    _buildDoubleActionButtons(
                        text1: "تمدید همین اشترا‌ک",
                        text2: "خرید اشتراک جدید",
                        color: greenColor,
                        onTap1: () {
                          // اول چک می‌کنیم اشتراک رایگان نباشه و دیتایی لود شده باشه
                          if (subModel != null && !subModel!.period.isFree) {
                            Navigator.pop(context); // دیالوگ اخطار رو می‌بندیم
                            // دیالوگ پرداخت رو برای همین اشتراک باز می‌کنیم
                            CheckoutUtils.checkOutDialog(
                              context,
                              subCode,
                              subModel!.period.periodPrice,
                              subModel!.period.id,
                              subModel!.period.periodName,
                            );
                          } else {
                            // اگر رایگان بود یا دیتایی نبود، می‌فرستیمش صفحه خرید جدید
                            Navigator.pop(context);
                            context.to(const PaymentScreen());
                          }
                        },
                        onTap2: () => context.to(const PaymentScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "مدیریت اشتراک ها",
                        text2: "ثبت کد اشتراک",
                        color: greenColor,
                        onTap1: () => context.to(const ProfileScreen()),
                        onTap2: () => showCooperationDialog4(context)),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "آموزش ها",
                        text2: "سوالات متداول",
                        color: greenColor,
                        onTap1: () => context.to(TrainingScreen()),
                        onTap2: () => context.to(const FAQScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "کیف پول",
                        text2: "پشتیبانی",
                        color: greenColor,
                        onTap1: () => context.to(const WalletScreen()),
                        onTap2: () => context.to(const SupportScreen())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleActionButtons(
      {required String text1,
        required String text2,
        required Color color,
        required VoidCallback onTap1,
        required VoidCallback onTap2}) {
    return Row(
      children: [
        Expanded(
            child: _buildActionButton(text: text1, color: color, onTap: onTap1)),
        const Gap(10),
        Expanded(
            child: _buildActionButton(text: text2, color: color, onTap: onTap2)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String text,
        required Color color,
        required VoidCallback onTap}) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          foregroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
void showCooperationDialog7(BuildContext context) async{
  await context.read<SplashProvider>().getSetting(context,false);
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




class CooperationDialogContent8 extends StatefulWidget {
  const CooperationDialogContent8({super.key});

  @override
  State<CooperationDialogContent8> createState() =>
      _CooperationDialogContent8State();
}

class _CooperationDialogContent8State extends State<CooperationDialogContent8> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                      "اطلاعیه غیر فعال بودن اشتراک",
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
                      "دلایل نمایش این اطلاعیه:\n۱- با فیلترشکن روشن وارد برنامه شدید ( فیلترشکن را خاموش کنید، برنامه را بسته و مجدد وارد شوید )\n۲- به اشتراکی وصل بودید که خریدار اشترک گزینه ی تغییر کد اشتراک را زده است\n۳- ارتباط اپلیکیشن با سرور قطع شده است",
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6, // فاصله بین خطوط برای خوانایی بهتر
                      ),
                    ),
                    const Gap(40),
                    // دکمه پشتیبانی آنلاین

                    _buildDoubleActionButtons(
                        text1: "خرید اشتراک",
                        text2: "مدیریت اشتراک ها",
                        color: greenColor,
                        onTap1: () => context.to(const PaymentScreen()),
                        onTap2: () => context.to(const ProfileScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "ثبت کد اشتراک",
                        text2: "ارتباط با پشتیبانی",
                        color: greenColor,
                        onTap1: () =>  showCooperationDialog4(context),
                        onTap2: () => context.to(const SupportScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "آموزش ها",
                        text2: "سوالات متداول",
                        color: greenColor,
                        onTap1: () => context.to(TrainingScreen()),
                        onTap2: () => context.to(const FAQScreen())),
                    const Gap(10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleActionButtons(
      {required String text1,
        required String text2,
        required Color color,
        required VoidCallback onTap1,
        required VoidCallback onTap2}) {
    return Row(
      children: [
        Expanded(
            child: _buildActionButton(text: text1, color: color, onTap: onTap1)),
        const Gap(10),
        Expanded(
            child: _buildActionButton(text: text2, color: color, onTap: onTap2)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String text,
        required Color color,
        required VoidCallback onTap}) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          foregroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}



class CooperationDialogContent9 extends StatefulWidget {
  const CooperationDialogContent9({super.key});

  @override
  State<CooperationDialogContent9> createState() =>
      _CooperationDialogContent9State();
}

class _CooperationDialogContent9State extends State<CooperationDialogContent9> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                      "اطلاعیه فعال سازی اشتراک",
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
                      "جهت ادامه ی فعالیت در این اپلیکیشن، میبایست اشتراک جدید خریداری کنید.\nدرصورتی که از قبل اشتراکی دارید که هنوز منقضی نشده، وارد بخش مدیریت اشتراک ها شده و اشتراک مورد نظر را فعال کنید.",
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
                      text: "خرید اشتراک",
                      color: greenColor,
                      onTap: () {
                        context.pop();
                          context.to(PaymentScreen());
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



class CooperationDialogContent10 extends StatefulWidget {
  const CooperationDialogContent10({super.key});

  @override
  State<CooperationDialogContent10> createState() =>
      _CooperationDialogContent10State();
}

class _CooperationDialogContent10State extends State<CooperationDialogContent10> {
  String subCode = "";
  Sub? subModel;
  String remainingDays = "0";
  String formattedTraffic = "0";

  @override
  void initState() {
    Future.microtask(
          () async {
        subModel = await Sub.getDB();
        subCode = await PrefHelpers.getSubCode();

        if (subModel != null) {
          int diff = subModel!.subDay.toLocal().difference(DateTime.now()).inDays;
          remainingDays = diff > 0 ? diff.toString() : "0";

          String totalTraffic = subModel!.period.traffic?.toString() ?? "0";
          formattedTraffic = (int.parse(totalTraffic) * 1024 * 1024)
              .size()
              .replaceAll("i", "");
        }

        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const greenColor = Color(0xFF1B5E20);
    return Center(
      child: Container(
        width: size.width * 0.90,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C313C), Color(0xFF0D0E11)],
          ),
          borderRadius: BorderRadius.circular(35),
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
                    'assets/images/egel.png',
                    height: 100,
                    opacity: const AlwaysStoppedAnimation(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "اطلاعیه اتمام حجم ترافیک مصرفی",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 3.0,
                                color: Colors.black45),
                          ]),
                    ),
                    const Gap(25),
                    RichText(
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.8),
                        children: [
                          const TextSpan(text: "کاربر گرامی،\nاز اشتراک شما ("),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: subCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("کد اشتراک کپی شد"),
                                      backgroundColor: Colors.green),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Gap(4),
                                  Text(subCode,
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const Gap(4),
                                  const Icon(Icons.copy,
                                      color: Colors.red, size: 14),
                                  const Gap(4),
                                ],
                              ),
                            ),
                          ),
                          TextSpan(
                              text:
                              ")، $remainingDays روز دیگر اعتبار باقی مانده است، اما ترافیک مجاز مصرفی شما ($formattedTraffic) به پایان رسیده است.\nلطفاً جهت تمدید همین اشتراک با همین پلن، گزینه \"تمدید همین اشترا‌ک\" را انتخاب نمایید. در صورتی که قصد خرید پلن های دیگری را دارید، گزینه \"خرید اشتراک جدید\" را انتخاب کنید.\nهمچنین، در صورتی که از قبل اشتراک فعال دیگری دارید، می‌توانید از بخش \"مدیریت اشتراک ها\" اقدام به فعال‌سازی آن نمایید."),
                        ],
                      ),
                    ),
                    const Gap(30),
                    _buildDoubleActionButtons(
                        text1: "تمدید همین اشترا‌ک",
                        text2: "خرید اشتراک جدید",
                        color: greenColor,
                        onTap1: () {
                          // اول چک می‌کنیم اشتراک رایگان نباشه و دیتایی لود شده باشه
                          if (subModel != null && !subModel!.period.isFree) {
                            Navigator.pop(context); // دیالوگ اخطار رو می‌بندیم
                            // دیالوگ پرداخت رو برای همین اشتراک باز می‌کنیم
                            CheckoutUtils.checkOutDialog(
                              context,
                              subCode,
                              subModel!.period.periodPrice,
                              subModel!.period.id,
                              subModel!.period.periodName,
                            );
                          } else {
                            // اگر رایگان بود یا دیتایی نبود، می‌فرستیمش صفحه خرید جدید
                            Navigator.pop(context);
                            context.to(const PaymentScreen());
                          }
                        },
                        onTap2: () => context.to(const PaymentScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "مدیریت اشتراک ها",
                        text2: "ثبت کد اشتراک",
                        color: greenColor,
                        onTap1: () => context.to(const ProfileScreen()),
                        onTap2: () => showCooperationDialog4(context)),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "آموزش ها",
                        text2: "سوالات متداول",
                        color: greenColor,
                        onTap1: () => context.to(TrainingScreen()),
                        onTap2: () => context.to(const FAQScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "کیف پول",
                        text2: "پشتیبانی",
                        color: greenColor,
                        onTap1: () => context.to(const WalletScreen()),
                        onTap2: () => context.to(const SupportScreen())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleActionButtons(
      {required String text1,
        required String text2,
        required Color color,
        required VoidCallback onTap1,
        required VoidCallback onTap2}) {
    return Row(
      children: [
        Expanded(
            child: _buildActionButton(text: text1, color: color, onTap: onTap1)),
        const Gap(10),
        Expanded(
            child: _buildActionButton(text: text2, color: color, onTap: onTap2)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String text,
        required Color color,
        required VoidCallback onTap}) {
    return SizedBox(
      height: 45,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          foregroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


class CooperationDialogContent11 extends StatefulWidget {
  const CooperationDialogContent11({super.key});

  @override
  State<CooperationDialogContent11> createState() =>
      _CooperationDialogContent11State();
}

class _CooperationDialogContent11State extends State<CooperationDialogContent11> {
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
    const greenColor = Color(0xFF1B5E20);

    return Center(
      child: Container(
        width: size.width * 0.90,
        constraints: BoxConstraints(maxWidth: 400,maxHeight: size.height * .75),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C313C), Color(0xFF0D0E11)],
          ),
          borderRadius: BorderRadius.circular(35),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "اطلاعیه اتمام حجم یا زمان اشتراک رایگان",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 3.0,
                                color: Colors.black45),
                          ]),
                    ),
                    const Gap(25),
                    RichText(
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.8),
                        children: [
                          const TextSpan(text: "کاربر گرامی !\nاعتبار اشتراک نسخه ی رایگان و آزمایشی شما با کد اشتراک "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: subCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("کد اشتراک کپی شد"),
                                      backgroundColor: Colors.green),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Gap(4),
                                  Text(subCode,
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const Gap(4),
                                  const Icon(Icons.copy,
                                      color: Colors.red, size: 14),
                                  const Gap(4),
                                ],
                              ),
                            ),
                          ),
                          const TextSpan(
                              text: " به اتمام رسیده است. لطفا از دکمه ی زیر، اقدام به خرید اشتراک نمایید."),
                        ],
                      ),
                    ),
                    const Gap(30),
                    // ردیف اول: تک دکمه
                    _buildActionButton(
                      text: "خرید اشتراک و فعالسازی",
                      color: greenColor,
                      onTap: () => context.to(const PaymentScreen()),
                    ),
                    const Gap(10),
                    // بقیه دکمه‌ها (دو ردیفی)
                    _buildDoubleActionButtons(
                        text1: "مدیریت اشتراک ها",
                        text2: "ثبت کد اشتراک",
                        color: greenColor,
                        onTap1: () => context.to(const ProfileScreen()),
                        onTap2: () => showCooperationDialog4(context)),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "آموزش ها",
                        text2: "سوالات متداول",
                        color: greenColor,
                        onTap1: () => context.to(TrainingScreen()),
                        onTap2: () => context.to(const FAQScreen())),
                    const Gap(10),
                    _buildDoubleActionButtons(
                        text1: "کیف پول",
                        text2: "ارتباط با پشتیبانی",
                        color: greenColor,
                        onTap1: () => context.to(const WalletScreen()),
                        onTap2: () => context.to(const SupportScreen())),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/egel.png',
                  height: 100,
                  opacity: const AlwaysStoppedAnimation(0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleActionButtons(
      {required String text1,
        required String text2,
        required Color color,
        required VoidCallback onTap1,
        required VoidCallback onTap2}) {
    return Row(
      children: [
        Expanded(
            child: _buildActionButton(text: text1, color: color, onTap: onTap1)),
        const Gap(10),
        Expanded(
            child: _buildActionButton(text: text2, color: color, onTap: onTap2)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String text,
        required Color color,
        required VoidCallback onTap}) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          foregroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
