import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsi/provider/baclground_service_Provider.dart';
import 'package:parsi/provider/notification_provider.dart';
import 'package:parsi/provider/pop_up_provider.dart';
import 'package:parsi/provider/server_provider.dart';
import 'package:parsi/provider/splash_provider.dart';
import 'package:parsi/provider/traning_provider.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:parsi/provider/v2ray_provider.dart';
import 'package:parsi/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await windowManager.ensureInitialized();
  // final pref = await SharedPreferences.getInstance();
  // await pref.clear();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(400, 900),
    center: true, // باز شدن پنجره در وسط صفحه
    backgroundColor: Colors.transparent,
    skipTaskbar: false,title: "Parsi Vpn",
    titleBarStyle: TitleBarStyle.normal,
  );

  // 5. اعمال تنظیمات و نمایش پنجره
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // --- نکته کلیدی اینجاست ---
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(const Size(400, 900));
    await windowManager.setMaximumSize(const Size(400, 900));
    // -------------------------
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => ServerProvider()),
        ChangeNotifierProvider(create: (_) => PopUpProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VpnProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProxyProvider2<UserProvider, VpnProvider,
            BackgroundServiceProvider>(
          create: (context) => BackgroundServiceProvider(),
          update: (context, userProvider, vpnProvider, backgroundService) {
            if (backgroundService == null) return BackgroundServiceProvider();
            // backgroundService.updateDependencies(userProvider, vpnProvider);
            return backgroundService;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale('en', 'US'),
      theme: ThemeData(
        fontFamily: "BHoma",
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // builder: (context, child) {
      //   // return SafeArea(child: child ?? SizedBox());
      // },
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
