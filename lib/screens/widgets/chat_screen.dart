import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const Color bgCol = Color(0xff2A2D32);
const Color bgColDark = Color(0xff131313);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  double _loadProgress = 0.0;

  final String _url = 'https://chat.parsi1.sbs/';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColDark)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadProgress = progress / 100;
            });

            // برای UX بهتر، زودتر لودینگ رو بردار
            if (progress > 80 && _isLoading) {
              setState(() => _isLoading = false);
            }
          },
          onPageFinished: (_) async {
            if (!mounted) return;

            // اطمینان از اسکرول درست
            await _controller.runJavaScript("""
              document.body.style.overflow = 'auto';
              document.body.style.height = '100vh';
            """);

            if (_isLoading) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColDark,
        body: Stack(
          children: [
            /// WebView تمام‌صفحه و ریسپانسیو
            const SizedBox.expand(
              child: _WebViewWrapper(),
            ),

            /// لودینگ
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: bgColDark,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'در حال بارگذاری... %${(_loadProgress * 100).toInt()}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            /// دکمه بازگشت
            Positioned(
              top: 15,
              left: 15,
              child: GestureDetector(
                onTap: _handleBack,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: bgCol.withOpacity(0.85),
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
          ],
        ),
      ),
    );
  }
}

/// ویجت جدا برای جلوگیری از rebuild ناخواسته WebView
class _WebViewWrapper extends StatelessWidget {
  const _WebViewWrapper();

  @override
  Widget build(BuildContext context) {
    final controller =
        (context.findAncestorStateOfType<_ChatScreenState>()!)._controller;

    return WebViewWidget(controller: controller);
  }
}
