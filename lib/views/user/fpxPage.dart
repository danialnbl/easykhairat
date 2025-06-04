import 'package:easykhairat/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/models/paymentModel.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:easykhairat/controllers/toyyibpay_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_links/app_links.dart';
import 'package:universal_html/html.dart' as html;

class PaymentPage extends StatefulWidget {
  final String billCode;
  final int feeId;
  final String userId;
  final double amount;
  final String description;

  const PaymentPage({
    Key? key,
    required this.billCode,
    required this.feeId,
    required this.userId,
    required this.amount,
    required this.description,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  final PaymentController paymentController = Get.put(PaymentController());
  bool _isLoading = true;
  bool _paymentCompleted = false;
  // Add a flag to track if payment has already been recorded to prevent duplicates
  bool _paymentRecorded = false;
  Timer? _statusCheckTimer;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize deep link handling
    _initDeepLinkHandling();

    // Launch external browser for both web and mobile
    _launchExternalBrowser();

    // Start checking payment status immediately
    _startCheckingPaymentStatus();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  // Initialize deep link handling
  Future<void> _initDeepLinkHandling() async {
    // Handle incoming links when app is already running
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (Object err) {
        print('Error getting uri links: $err');
      },
    );

    // Handle links that opened the app from terminated state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }
    } catch (e) {
      print('Error handling initial deep link: $e');
    }
  }

  // Handle the incoming link
  void _handleIncomingLink(Uri? uri) {
    if (uri == null) return;

    print('Deep link received: $uri');

    // Check if this is our payment status deep link
    if (uri.scheme == 'easykhairat' && uri.host == 'payment-status') {
      // Extract status from query parameters if available
      final status =
          uri.queryParameters['status'] ??
          uri.queryParameters['status_id'] ??
          '';

      // DON'T navigate to any routes here - just check the payment status
      if (status == '1') {
        print('Payment success detected via deep link');
        // Immediately check payment status and update UI
        _checkPaymentStatus();
      }
    }
  }

  void _startCheckingPaymentStatus() {
    // Check payment status every 5 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    // Skip check if payment was already recorded
    if (_paymentRecorded) {
      print('Payment already recorded, skipping status check');
      return;
    }

    // Use ToyyibPay API to check payment status
    try {
      final toyyibPayService = ToyyibPayService();
      final status = await toyyibPayService.getBillPaymentStatus(
        widget.billCode,
      );

      print(
        'Payment status check result: $status for bill: ${widget.billCode}',
      );

      if (status == 1 && !_paymentRecorded) {
        // Payment successful
        _statusCheckTimer?.cancel();
        await _recordSuccessfulPayment();
        setState(() => _paymentCompleted = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pembayaran berjaya! Rekod telah dikemaskini."),
              backgroundColor: Colors.green,
            ),
          );

          // Instead of just popping, check if we need to handle deep link navigation
          Future.delayed(const Duration(seconds: 2), () {
            // If opened from deep link and not navigated properly
            if (Navigator.of(context).canPop()) {
              // Safe to pop back
              Navigator.of(context).pop(true);
            } else {
              // App was likely launched from deep link, navigate to home
              Get.offAllNamed(AppRoutes.home);
            }
          });
        }
      } else if (status == 3) {
        // Failed payment
        _statusCheckTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pembayaran gagal. Sila cuba lagi."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking payment status: $e');
    }
  }

  Future<void> _recordSuccessfulPayment() async {
    // Check if payment has already been recorded to prevent duplicates
    if (_paymentRecorded) {
      print('Payment already recorded, skipping duplicate submission');
      return;
    }

    try {
      // Mark as recorded immediately to prevent race conditions
      _paymentRecorded = true;

      print('Recording payment for bill: ${widget.billCode}');

      // Try to get transaction details from ToyyibPay
      final toyyibPayService = ToyyibPayService();
      final transactionDetails = await toyyibPayService
          .getBillTransactionDetails(widget.billCode);

      // Use billCode as reference ID to prevent duplicates
      // Create payment record to be saved in Supabase
      final payment = PaymentModel(
        paymentValue: widget.amount,
        paymentDescription: widget.description,
        paymentCreatedAt: DateTime.now(),
        paymentUpdatedAt: DateTime.now(),
        feeId: widget.feeId,
        userId: widget.userId,
        paymentType: 'FPX',
        referenceId:
            widget.billCode, // Store billCode as reference for deduplication
      );

      // Save payment record to Supabase
      await paymentController.addPayment(payment);
      print('Payment recorded successfully for bill: ${widget.billCode}');
    } catch (error) {
      print('Error recording payment: $error');
      // Note: We don't reset _paymentRecorded flag even on error
      // This prevents repeated attempts that could lead to duplicates
    }
  }

  void _launchExternalBrowser() async {
    final url = 'https://dev.toyyibpay.com/${widget.billCode}';

    try {
      // Launch URL in external browser
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication, // This forces external browser
        );
      } else {
        print('Could not launch $url');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Tidak dapat membuka laman pembayaran. Sila cuba lagi.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          )
          ..enableZoom(true)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                print('WebView loading: $progress%');
                if (progress == 100) {
                  setState(() => _isLoading = false);
                  Future.delayed(Duration(milliseconds: 500), () {
                    _injectScrollFixes();
                  });
                }
              },
              onPageStarted: (url) => print('Page started: $url'),
              onPageFinished: (url) {
                print('Page finished: $url');
                _injectScrollFixes();

                // Check if URL contains success parameters, but don't record if already done
                if ((url.contains('status=1') || url.contains('status_id=1')) &&
                    !_paymentRecorded) {
                  _statusCheckTimer?.cancel();
                  _recordSuccessfulPayment();
                  setState(() => _paymentCompleted = true);
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                print('Navigating to: ${request.url}');

                // If the URL contains the return URL pattern
                if ((request.url.contains('payment-status') ||
                        request.url.contains('return_url')) &&
                    !_paymentRecorded) {
                  _checkPaymentStatus();
                }
                return NavigationDecision.navigate;
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView error: ${error.description}');
                // Retry loading if it's a renderer crash
                if (error.errorCode == -1 && !_isLoading) {
                  Future.delayed(Duration(seconds: 1), () {
                    _controller.reload();
                  });
                }
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://dev.toyyibpay.com/${widget.billCode}'),
          );
  }

  void _injectScrollFixes() {
    _controller.runJavaScript('''
      try {
        // Simpler viewport setting
        var viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
          viewport.setAttribute('content', 'width=device-width, initial-scale=1.0');
        } else {
          var newViewport = document.createElement('meta');
          newViewport.name = 'viewport';
          newViewport.content = 'width=device-width, initial-scale=1.0';
          document.head.appendChild(newViewport);
        }
        
        // Basic styling fixes
        document.body.style.zoom = "1.0";
        document.body.style.minHeight = "100vh";
        document.body.style.width = "100%";
        document.body.style.overflow = "auto";
        document.documentElement.style.overflow = "auto";
        
        // Add custom styles to fix ToyyibPay specifically
        var style = document.createElement('style');
        style.textContent = `
          * { box-sizing: border-box; }
          body { -webkit-overflow-scrolling: touch; padding-bottom: 50px; }
          .container { max-width: 100% !important; width: 100% !important; padding: 10px !important; }
          form { width: 100% !important; }
          .card { width: 100% !important; overflow: visible !important; }
          .card-body { padding: 12px !important; }
          input, select { max-width: 100% !important; }
          table { width: 100% !important; display: block; overflow-x: auto; }
        `;
        document.head.appendChild(style);
      } catch (err) {
        console.error("Error applying WebView fixes:", err);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog if payment is in progress
        if (!_paymentCompleted && !_isLoading) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Batalkan Pembayaran?'),
                  content: const Text(
                    'Adakah anda pasti mahu batalkan pembayaran? Pembayaran yang belum selesai tidak akan direkodkan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('TIDAK'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('YA'),
                    ),
                  ],
                ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran Yuran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!_paymentCompleted) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Batalkan Pembayaran?'),
                        content: const Text(
                          'Adakah anda pasti mahu batalkan pembayaran? Pembayaran yang belum selesai tidak akan direkodkan.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('TIDAK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Exit payment page
                            },
                            child: const Text('YA'),
                          ),
                        ],
                      ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 30),
                Text(
                  "Pembayaran Sedang Diproses",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Anda telah dialihkan ke laman pembayaran dalam pelayar web. Sila lengkapkan pembayaran anda dan jangan tutup aplikasi ini.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(),
                SizedBox(height: 30),
                Text(
                  "Status pembayaran akan dikemaskini secara automatik selepas pembayaran berjaya.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display iframe on web
class WebPaymentWidget extends StatelessWidget {
  final String url;
  const WebPaymentWidget({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Launch the payment URL automatically when on web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      html.window.open(url, '_self');
    });

    return Container(
      height: MediaQuery.of(context).size.height, // Set to full screen height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensure it's always scrollable
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(
                  context,
                ).size.height, // Ensures content fills screen
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Anda akan dialihkan ke laman pembayaran yang selamat. Sila tunggu sebentar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated loading indicator
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Cancel button
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                    label: Text(
                      "Kembali",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
