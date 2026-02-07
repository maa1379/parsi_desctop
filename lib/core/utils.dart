import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/core/Flutter-Neumorphic-master/lib/flutter_neumorphic.dart';

class Utils {
  static String replaceFarsiToEnglishNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < farsi.length; i++) {
      input = input.replaceAll(farsi[i], english[i]);
    }
    return input;
  }

  static final CacheManager instance = CacheManager(
    Config(
      "customCacheKey",
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: "customCacheKey"),
      fileService: HttpFileService(),
    ),
  );

  static double checkTrafficUsageForSize(String data) {
    double download = 0;
    if (data.contains("KiB")) {
      download = double.parse(data.split("KiB")[0]) * 1024;
    } else if (data.contains("MiB")) {
      download = double.parse(data.split("MiB")[0]) * 1024 * 1024;
    } else if (data.contains("GiB")) {
      download = double.parse(data.split("GiB")[0]) * 1024 * 1024 * 1024;
    } else {
      download = 0;
    }
    return download;
  }

  static String checkDate(DateTime d) {
    final now = DateTime.now();
    final difference = d.difference(now);

    if (difference.isNegative) return "0";

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return "$days روز ${hours > 0 ? "$hours ساعت" : ""}".trim();
    } else if (hours > 0) {
      return "$hours ساعت ${minutes > 0 ? "$minutes دقیقه" : ""}".trim();
    } else {
      return "$minutes دقیقه";
    }
  }

  static AppBar appBarWidget(BuildContext context) {
    return AppBar(
      actions: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child:
                  Container(
                    width: 55,
                    height: 55,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ).neuShape,
            ),
          ),
        ),
      ],
      leading: const SizedBox.shrink(),
      backgroundColor: Colors.transparent,
    );
  }
}

extension NeumorphicContainer on Container {
  Widget get neuShadow {
    return Neumorphic(
      style: NeumorphicStyle(
        border: NeumorphicBorder(
          color: Colors.grey.withOpacity(0.5),
          width: .8,
        ),
        depth: -5,
        color: Colors.black12,
        shadowLightColorEmboss: Colors.white.withOpacity(.3),
        shadowDarkColorEmboss: Colors.black,
      ),
      child: this,
    );
  }

  Widget get neuShape {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: const NeumorphicBoxShape.circle(),
        border: NeumorphicBorder(
          color: Colors.grey.withOpacity(0.5),
          width: .8,
        ),
        depth: -5,
        color: Colors.black12,
        shadowLightColorEmboss: Colors.white.withOpacity(.3),
        shadowDarkColorEmboss: Colors.black,
      ),
      child: this,
    );
  }
}
