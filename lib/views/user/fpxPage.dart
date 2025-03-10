import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String billCode;

  const PaymentPage({Key? key, required this.billCode}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress:
                  (progress) => debugPrint('WebView loading: $progress%'),
              onPageStarted: (url) => debugPrint('Page started: $url'),
              onPageFinished: (url) => debugPrint('Page finished: $url'),
              onNavigationRequest: (NavigationRequest request) {
                debugPrint('Navigating to: ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://dev.toyyibpay.com/${widget.billCode}'),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body:
          kIsWeb
              ? WebPaymentWidget(
                url: 'https://dev.toyyibpay.com/${widget.billCode}',
              )
              : WebViewWidget(controller: _controller),
    );
  }
}

// Widget to display iframe on web
class WebPaymentWidget extends StatelessWidget {
  final String url;
  const WebPaymentWidget({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("Redirecting to payment..."),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: const Center(
                child: CircularProgressIndicator(), // Show loading indicator
              ),
            ),
          ),
        ],
      ),
    );
  }
}
