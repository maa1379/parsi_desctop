import 'package:auto_size_text/auto_size_text.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/screens/payment_screen.dart';
import 'package:parsi/screens/profile_screen.dart';
import 'package:parsi/screens/support_screen.dart';
import 'package:parsi/screens/wallet_screen.dart';
import 'package:parsi/screens/widgets/build_config_widget.dart';
import 'package:parsi/screens/widgets/chat_screen.dart';
import 'package:parsi/screens/widgets/showCooperationDialog.dart';
import 'package:parsi/screens/widgets/speed_test/speed_test_screen.dart';
import 'package:provider/provider.dart';

import '../core/Flutter-Neumorphic-master/lib/flutter_neumorphic.dart';
import '../generated/assets.dart';
import '../provider/v2ray_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.widget,});
  final Widget widget;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Size size = MediaQuery.sizeOf(context);

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        _buildTopImage(),
        widget.widget,
        BuildConfigWidget().configWidget(size),
        _buildBuildChips(),
      ],
    );
  }


  Widget _buildBuildChips() {
    return Column(
      children: [
        const Gap(30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildChipItem("خرید اشتراک", () {
              context.to(const PaymentScreen());
            }),
            _buildChipItem("اشتراک ها", () {
              context.to(const ProfileScreen());
            }),
            _buildChipItem(
              "وضعیت سرور",
              () {
                showCooperationDialog7(context);
              },
            ),
          ],
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildChipItem("چت روم", () {
              context.to(const ChatScreen());
              // context.to(const SpeedTestScreen());
            }),
            _buildChipItem(
              "کیف پول",
              () {
                context.to(const WalletScreen());
              },
            ),
            _buildChipItem("پشتیبانی", () {
              context.to(SupportScreen());
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildChipItem(String title, Function() onTap, {double? width}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: size.height * .04,
        width: width ?? size.width * .2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff24272C),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.06),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(-5, -5)),
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(5, 5)),
          ],
        ),
        child: AutoSizeText(
          title,
          textAlign: TextAlign.center,
          minFontSize: 6,
          maxFontSize: 12,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Padding _buildTopImage() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 80,
        left: 80,
        top: 100,
      ),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.white12, blurRadius: 10, spreadRadius: 1)
            ]),
        child: Lottie.asset(
          // استفاده از VpnProvider به جای V2rayProvider
          controller: context.watch<VpnProvider>().animationController,
          Assets.assetsImagesPirooz,
          addRepaintBoundary: true,
          repeat: false,
        ),
      ),
    );
  }
}
