import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../provider/v2ray_provider.dart';

class ShowPingWidget extends StatelessWidget {
  ShowPingWidget({super.key});

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    // ویجت پینگ فقط برای V2Ray نمایش داده می‌شود
    // (و یا باید منطق پینگ WireGuard اضافه شود)
    return buildShowV2rayPing();
  }

  Widget buildShowV2rayPing() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Consumer<VpnProvider>(builder: (context, vpnProvider, child) {
          final bool isConnected =
              vpnProvider.state == VpnConnectionState.connected;

          if (!isConnected) {
            return GestureDetector(
              onTap: () async {
                // لاجیک اتصال یا تلاش مجدد در صورت نیاز
              },
              child: SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AutoSizeText(
                      "متصل نیست",
                      minFontSize: 10,
                      textAlign: TextAlign.end,
                      maxFontSize: 18,
                    ),
                  ],
                ),
              ),
            );
          }

          final RegExp pingRegex = RegExp(r'\d+');
          final String pingText = vpnProvider.ping;

          final Match? match = pingRegex.firstMatch(pingText);
          final String? pingNumber = match?.group(0);
          // --- بخش اصلی تغییر کرده ---
          return GestureDetector(
            onTap: () async {
              if (isConnected && !vpnProvider.showPing) {
                await vpnProvider.updatePing();
              }
            },
            child: SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(80),
                  const AutoSizeText(
                    "متصل شد.  ",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  // شرط نمایش لودینگ یا مقدار پینگ
                  if (vpnProvider.showPing)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white, // رنگ لودینگ
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          pingText.replaceFirst(pingNumber ?? '', ''),
                          style: TextStyle(color: Colors.white),
                        ),
                        Visibility(
                          visible: pingNumber != null,
                          child: Text(
                            pingNumber == "0" ? "" : " ms  ",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Visibility(
                          visible: pingNumber != null,
                          child: Text(
                            pingNumber == "0" ? "" : "$pingNumber",
                            style: TextStyle(color: Colors.green, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
