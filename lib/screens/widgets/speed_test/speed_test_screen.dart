import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/nav_helper.dart'; // فرض بر وجود این فایل
import '../../../core/utils.dart';     // فرض بر وجود این فایل

const Color bgCol = Color(0xff2A2D32);
const Color bgColDark = Color(0xff131313);

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadProgress = 0.0; // برای نمایش دقیق‌تر وضعیت

  // تغییر مهم ۱: استفاده از fast.com بخاطر سبک بودن و شروع خودکار
  final String _url = 'http://www.speedcheck.ir/';
  // اگر حتما کلودفلر را می‌خواهید، آن را آنکامنت کنید ولی سنگین‌تر است
  // final String _url = 'https://speed.cloudflare.com/';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColDark) // همرنگ کردن بک‌گراند وب‌ویو با اپ
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          // تغییر مهم ۲: استفاده از onProgress برای حذف سریع‌تر لودینگ
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadProgress = progress / 100;
              });
              // اگر بیشتر از ۸۰ درصد لود شد، لودینگ را بردار (منتظر ۱۰۰٪ نمان)
              if (progress > 80 && _isLoading) {
                setState(() => _isLoading = false);
              }
            }
          },
          onPageFinished: (String url) {
            // محض اطمینان، اگر تا اینجا هنوز loading بود، حذفش کن
            if (mounted && _isLoading) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColDark,
        body: Stack(
          children: [
            // وب‌ویو
            WebViewWidget(controller: _controller),

            // لایه لودینگ
            if (_isLoading)
              Container(
                color: bgColDark,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.greenAccent),
                      const SizedBox(height: 20),
                      Text(
                        // نمایش درصد پیشرفت برای حس بهتر به کاربر
                        "در حال بارگذاری... %${(_loadProgress * 100).toInt()}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // دکمه بازگشت
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 15), // کمی فاصله از بالا
                child: GestureDetector(
                  onTap: () {
                    // اول چک میکنیم اگر صفحه وب عقب میرود، برگردد
                    _controller.canGoBack().then((value) {
                      if (value) {
                        _controller.goBack();
                      } else {
                        Navigator.pop(context); // استفاده از نویگیتور استاندارد اگر context.pop کار نکرد
                      }
                    });
                  },
                  child: Container(
                    width: 45, // سایز کمی جمع‌وجورتر
                    height: 45,
                    decoration: BoxDecoration( // اگر neuShape نبود این کار میکند
                      color: bgCol.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}