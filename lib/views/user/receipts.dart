import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/models/paymentModel.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Receipts extends StatefulWidget {
  const Receipts({Key? key}) : super(key: key);

  @override
  _ReceiptsState createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {
  final PaymentController paymentController = Get.put(PaymentController());
  final supabase = Supabase.instance.client;
  final RxString currentUserId = ''.obs;
  StreamSubscription? _paymentsSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndLoadPayments();
  }

  Future<void> _getCurrentUserAndLoadPayments() async {
    try {
      // Get the current user from Supabase session
      final session = supabase.auth.currentSession;
      if (session != null) {
        // Get the user ID from the session
        final userId = session.user.id;
        currentUserId.value = userId;

        // Load payments for this user
        await paymentController.fetchPaymentsByUserId(userId);

        // Subscribe to real-time changes
        _subscribeToPaymentChanges();
      } else {
        // If no session is available, show error
        Get.snackbar(
          'Error',
          'Unable to retrieve user information. Please log in again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Optionally redirect to login page
        // Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'An error occurred while retrieving user information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadUserPayments() async {
    if (currentUserId.value.isNotEmpty) {
      await paymentController.fetchPaymentsByUserId(currentUserId.value);
    } else {
      // Try to get user ID again if it's not available
      await _getCurrentUserAndLoadPayments();
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _subscribeToPaymentChanges() {
    if (currentUserId.value.isEmpty) return;

    _paymentsSubscription = paymentController
        .streamPaymentsByUserId(currentUserId.value)
        .listen((payments) {
          // This will be called whenever the payments table changes for this user
          _loadUserPayments();
        });
  }

  @override
  void dispose() {
    _paymentsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MoonColors.light.gohan,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/easyKhairatLogo.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -5, end: -5),
                        badgeContent: Text(
                          '3',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            showMenu(
                              color: Colors.white,
                              context: context,
                              position: RelativeRect.fromLTRB(
                                MediaQuery.of(context).size.width - 150,
                                80,
                                16,
                                0,
                              ),
                              items: [
                                PopupMenuItem(
                                  child: ListTile(
                                    // Make this more compact
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    dense: true,
                                    leading: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4.0,
                                      ), // reduced padding
                                      child: Icon(
                                        Icons.check,
                                        color: MoonColors.light.bulma,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      'Mark all as read',
                                      style: TextStyle(
                                        color: MoonColors.light.bulma,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12, // smaller font
                                      ),
                                    ),
                                    tileColor: MoonColors.light.beerus,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                // Make the other menu items smaller too
                                PopupMenuItem(
                                  height: 40, // Shorter height
                                  child: Text(
                                    'Tuntutan Approved',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 40, // Shorter height
                                  child: Text(
                                    'Sila Bayar Yuran Tertunggak',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 40, // Shorter height
                                  child: Text(
                                    'Ahli keluarga baharu ditambah',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: MoonColors.light.piccolo),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Resit Pembayaran',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (paymentController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (paymentController.payments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _loadUserPayments,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: paymentController.payments.length,
                      itemBuilder: (context, index) {
                        final payment = paymentController.payments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MoonColors.light.beerus,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 60,
              color: MoonColors.light.hit,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Tiada Sejarah Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              'Anda belum mempunyai sejarah pembayaran. Semua resit pembayaran akan dipaparkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showReceiptDetails(payment),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // Add this
                  children: [
                    // First column - wrap this in Expanded to prevent overflow
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MoonColors.light.beerus,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.receipt,
                              color: MoonColors.light.hit,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            // Add this to make text wrap
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payment.paymentDescription,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Add this
                                  maxLines: 2, // Add this
                                ),
                                Text(
                                  formatDate(payment.paymentCreatedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8), // Add spacing between columns
                    // Second column - payment amount
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RM ${payment.paymentValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Add this to prevent overflow
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          SizedBox(width: 4),
                          Flexible(
                            // Add this to make text wrap if needed
                            child: Text(
                              'Pembayaran Diterima',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      payment.paymentType ?? 'Unknown',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReceiptDetails(PaymentModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    'Resit Pembayaran',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'RM ${payment.paymentValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('ID Pembayaran', '#${payment.paymentId}'),
                      Divider(),
                      _buildDetailRow('Penerangan', payment.paymentDescription),
                      Divider(),
                      _buildDetailRow(
                        'Tarikh',
                        formatDate(payment.paymentCreatedAt),
                      ),
                      Divider(),
                      _buildDetailRow(
                        'Kaedah Pembayaran',
                        payment.paymentType ?? 'Unknown',
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Muat Turun'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Download functionality would go here
                          Get.snackbar(
                            'Coming Soon',
                            'Download functionality will be added soon',
                            backgroundColor: MoonColors.light.hit,
                            colorText: Colors.white,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.share),
                        label: Text('Kongsi'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: MoonColors.light.beerus,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Share functionality would go here
                          Get.snackbar(
                            'Coming Soon',
                            'Share functionality will be added soon',
                            backgroundColor: MoonColors.light.hit,
                            colorText: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            // Add this
            flex: 1,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          SizedBox(width: 16), // Add some spacing
          Flexible(
            // Add this
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right, // Right-align the value
            ),
          ),
        ],
      ),
    );
  }
}
