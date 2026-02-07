import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowUpdateDialog{
 static void showInitDialog(BuildContext context,String appDownloadLink) {
    Size size = MediaQuery.sizeOf(context);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Scaffold(
          body: PopScope(
            canPop: false,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(
                    vertical: size.height * .35, horizontal: size.width * .1),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/back.png"),
                      fit: BoxFit.cover,
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "برای استفاده از اپلیکیشن باید ورژن جدید را دانلود و نصب کنید",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(15),
                    GestureDetector(
                      onTap: () async {
                        await launchUrl(
                          Uri.parse(appDownloadLink),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Container(
                        height: size.height * .05,
                        width: size.width * .35,
                        decoration: BoxDecoration(
                          color: const Color(0xff353A40),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const AutoSizeText(
                          "دانلود",
                          minFontSize: 16,
                          maxFontSize: 20,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).neuShadow,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}