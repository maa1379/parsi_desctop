import 'package:flutter/material.dart';
import 'package:parsi/provider/splash_provider.dart';
import 'package:provider/provider.dart';

import '../generated/assets.dart';
import '../core/view_helper.dart'; // برای نمایش خطا

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Size size = MediaQuery.sizeOf(context);

  @override
  void initState() {
    super.initState();
    Provider.of<SplashProvider>(context, listen: false).initData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (context, splashProvider, child) {
        return splashUi();
      },
    );
  }


  Widget splashUi() {
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/splash8.jpg",
                   fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Image.asset(Assets.imagesParsilogowite,height: 35,),
                    Text("Parsi Vpn",style: TextStyle(color: Colors.white,fontSize: 18),)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}