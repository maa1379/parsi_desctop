import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/number_formatters.dart';
import 'package:provider/provider.dart';

import '../../generated/assets.dart';
import '../../provider/v2ray_provider.dart';
import '../../provider/vpn_changer_state_service.dart';

class VpnSpeedWidget extends StatelessWidget {
  const VpnSpeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VpnState>(
      valueListenable: vpnStateNotifier,
      builder: (context, vpnState, child) {
        if (vpnState == VpnState.v2rayState) {
          return buildV2rayWidget(context); // ارسال context
        } else {
          return const SizedBox.shrink(); // برای WireGuard سرعت نمایش نده
        }
      },
    );
  }

  Widget buildV2rayWidget(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        (vpnProvider.state != VpnConnectionState.connected)?Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AutoSizeText(
              0.speed().replaceAll("i", ""),
              minFontSize: 12,
              maxFontSize: 20,
              style: const TextStyle(color: Colors.white),
            ),
            Image.asset(
              Assets.imagesMoveUp,
            ),
            const Gap(10),
            AutoSizeText(
              0.speed().replaceAll("i", ""),
              minFontSize: 12,
              maxFontSize: 20,
              style: const TextStyle(color: Colors.white),
            ),
            Image.asset(
              Assets.imagesMoveDown,
            ),
          ],
        ):
        StreamBuilder<VpnSpeedData>(
          stream: vpnProvider.speedStream,
          builder: (context, snapshot) {
            final speedData = snapshot.data;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  (int.parse(speedData?.upload ?? "0")).speed().replaceAll("i", ""),
                  minFontSize: 12,
                  maxFontSize: 20,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                ),
                Image.asset(
                  Assets.imagesMoveUp,
                ),
                const Gap(10),
                AutoSizeText(
                  (int.parse(speedData?.download ?? "0")).speed().replaceAll("i", ""),
                  textDirection: TextDirection.ltr,
                  minFontSize: 12,
                  maxFontSize: 20,
                  style: const TextStyle(color: Colors.white),
                ),
                Image.asset(
                  Assets.imagesMoveDown,
                ),
              ],
            );
          },
        ),
        Gap(5),
        StreamBuilder<VpnSpeedData>(
          stream: vpnProvider.speedStream,
          initialData: VpnSpeedData.zero(),
          builder: (context, snapshot) {
            final speedData = snapshot.data;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  speedData?.duration ?? "",
                  minFontSize: 16,
                  maxFontSize: 24,
                  style: const TextStyle(color: Colors.white),
                ),
                const Gap(5),
                const Icon(
                  Icons.access_time_outlined,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
