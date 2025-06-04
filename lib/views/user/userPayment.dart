import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/controllers/toyyibpay_service.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/models/feeModel.dart';
import 'package:easykhairat/views/user/fpxPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPayment extends StatefulWidget {
  const UserPayment({Key? key}) : super(key: key);

  @override
  _UserPaymentState createState() => _UserPaymentState();
}

class _UserPaymentState extends State<UserPayment> {
  final TextEditingController textAmountController = TextEditingController(
    text: "0.00",
  );
  final FeeController feeController = Get.put(FeeController());
  final PaymentController paymentController = Get.put(PaymentController());

  String? selectedFeeId;
  final RxBool isProcessing = false.obs;

  @override
  void initState() {
    super.initState();
    _loadUserFees();
  }

  Future<void> _loadUserFees() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      // Use the current user ID
      await feeController.fetchYuranTertunggak(currentUserId);
      await paymentController.fetchPaymentsByUserId(currentUserId);

      // Set default fee if available
      if (feeController.yuranTertunggak.isNotEmpty) {
        setState(() {
          selectedFeeId = feeController.yuranTertunggak.first.feeId.toString();
          textAmountController.text = feeController
              .yuranTertunggak
              .first
              .feeAmount
              .toStringAsFixed(2);
        });
      }
    } else {
      Get.snackbar('Error', 'User not authenticated');
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Column(
        children: [
          // Enhanced header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: MoonColors.light.bulma,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bayaran Yuran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPaymentData,
              color: MoonColors.light.bulma,
              backgroundColor: Colors.white,
              displacement: 20,
              strokeWidth: 3,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info header card
                    _buildInfoHeader(),

                    const SizedBox(height: 20),

                    // Payment summary card
                    _buildPaymentSummaryCard(),

                    const SizedBox(height: 24),

                    // Fees selection
                    _buildFeesSection(),

                    const SizedBox(height: 24),

                    // Payment history
                    _buildPaymentHistorySection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Bayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Selected fee details
            Obx(() {
              final selectedFee =
                  selectedFeeId != null
                      ? feeController.yuranTertunggak.firstWhereOrNull(
                        (fee) => fee.feeId.toString() == selectedFeeId,
                      )
                      : null;

              if (selectedFee == null) {
                if (feeController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Tiada Yuran Tertunggak",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Anda tidak mempunyai sebarang yuran untuk dibayar pada masa ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Jenis Yuran", selectedFee.feeDescription),
                  _buildInfoRow("Tarikh Akhir", formatDate(selectedFee.feeDue)),
                  _buildInfoRow(
                    "Jumlah",
                    "RM ${selectedFee.feeAmount.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 20),

                  // Amount input
                  Text(
                    'Jumlah Bayaran (RM)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextFormField(
                      controller: textAmountController,
                      decoration: InputDecoration(
                        labelText: "Jumlah Bayaran",
                        hintText: "0.00",
                        prefixIcon: Icon(Icons.attach_money),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        helperText: 'Tetapkan jumlah yang ingin dibayar',
                        helperStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      cursorColor: Colors.blue,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (value) {
                        // Format the value as currency while typing
                        if (value.isNotEmpty) {
                          final double? amount = double.tryParse(value);
                          if (amount != null) {
                            // Only update if it's a valid number to prevent cursor jumping
                            if (value != amount.toStringAsFixed(2)) {
                              textAmountController.value =
                                  TextEditingController.fromValue(
                                    TextEditingValue(
                                      text: amount.toStringAsFixed(2),
                                      selection: TextSelection.collapsed(
                                        offset: value.length,
                                      ),
                                    ),
                                  ).value;
                            }
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Minimum bayaran adalah RM2.00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment button
                  Obx(
                    () => MoonFilledButton(
                      borderRadius: BorderRadius.circular(12),
                      buttonSize: MoonButtonSize.md,
                      onTap:
                          isProcessing.value
                              ? null
                              : () => _processPayment(selectedFee),
                      isFullWidth: true,
                      // The issue is with the 'disabled' property - it's not supported in MoonFilledButton
                      // Instead, pass null to onTap to disable the button
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isProcessing.value)
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(right: 12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          Text(
                            isProcessing.value
                                ? "MEMPROSES..."
                                : "BAYAR SEKARANG",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Pilih Yuran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (feeController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feeController.yuranTertunggak.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Center(
                child: Text(
                  "Tiada yuran tertunggak",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ),
            );
          }

          return Column(
            children:
                feeController.yuranTertunggak.map((fee) {
                  bool isSelected = selectedFeeId == fee.feeId.toString();
                  bool isOverdue = fee.feeDue.isBefore(DateTime.now());

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.blue
                                : isOverdue
                                ? Colors.red.shade300
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected
                              ? Colors.blue.shade50
                              : isOverdue
                              ? Colors.red.shade50
                              : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedFeeId = fee.feeId.toString();
                          textAmountController.text = fee.feeAmount
                              .toStringAsFixed(2);
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Radio button
                            Radio<String>(
                              value: fee.feeId.toString(),
                              groupValue: selectedFeeId,
                              onChanged: (value) {
                                setState(() {
                                  selectedFeeId = value;
                                  textAmountController.text = fee.feeAmount
                                      .toStringAsFixed(2);
                                });
                              },
                              activeColor: Colors.blue,
                            ),

                            // Fee details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fee.feeDescription,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color:
                                          isSelected
                                              ? Colors.blue.shade700
                                              : isOverdue
                                              ? Colors.red.shade700
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tarikh Akhir: ${formatDate(fee.feeDue)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          isOverdue
                                              ? Colors.red.shade800
                                              : null,
                                    ),
                                  ),
                                  if (isOverdue)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "LEWAT TEMPOH",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Amount
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue.shade100
                                        : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "RM ${fee.feeAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.blue.shade700
                                          : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Sejarah Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Use a different approach to access the controller
        // to avoid naming confusion
        GetX<PaymentController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.payments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        "Tiada rekod pembayaran",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.payments.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final payment = controller.payments[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.check, color: Colors.green, size: 20),
                    ),
                    title: Text(payment.paymentDescription),
                    subtitle: Text(formatDate(payment.paymentCreatedAt)),
                    trailing: Text(
                      "RM ${payment.paymentValue.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoHeader() {
    return Card(
      color: MoonColors.light.bulma.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MoonIcons.generic_info_16_light,
                  color: MoonColors.light.bulma,
                ),
                SizedBox(width: 8),
                Text(
                  'Bayaran Yuran Khairat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Sila pilih yuran yang ingin dibayar dan masukkan jumlah bayaran. '
              'Pembayaran akan diproses melalui FPX.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(FeeModel fee) async {
    try {
      isProcessing.value = true;

      // Remove any "RM" prefix and trim spaces
      String paymentText =
          textAmountController.text.replaceAll(RegExp(r'[^\d.]'), '').trim();

      // Convert cleaned string to double
      double? payment = double.tryParse(paymentText);

      if (payment == null || payment < 2.0) {
        throw Exception('Minimum payment amount is RM2.00');
      }

      // Get current user from Supabase
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) {
        throw Exception('User not authenticated');
      }

      final currentUserId = supabaseUser.id;

      // Get user details from your controller to ensure the user exists
      final userController = Get.put(UserController());
      final user = await userController.fetchUserById(currentUserId);

      if (user == null) {
        throw Exception('User profile not found');
      }

      print(
        'Processing payment for user: ${user.userName} (ID: ${user.userId})',
      );

      // Generate the bill
      final toyyibPayService = ToyyibPayService();
      String? billCode = await toyyibPayService.createBill(
        billTitle: 'Payment for ${fee.feeDescription}',
        billDescription: 'Payment for Fee ID: ${fee.feeId}',
        billAmount: (payment * 100).toStringAsFixed(0),
        userEmail: user.userEmail, // Use actual user email
        userPhone:
            user.userPhoneNo ?? "0123456789", // Use actual phone if available
        categoryCode: 'r53xplxf',
      );

      if (billCode != null) {
        // Store session data locally before navigation
        final currentSession = Supabase.instance.client.auth.currentSession;

        // Navigate to the payment page with all required parameters
        final paymentResult = await Get.to(
          () => PaymentPage(
            billCode: billCode,
            feeId: fee.feeId!,
            userId: currentUserId,
            amount: payment,
            description: 'Payment for ${fee.feeDescription}',
          ),
        );

        // After returning from payment page, check if we need to restore session
        if (Supabase.instance.client.auth.currentSession == null) {
          print('Session lost after payment, attempting to restore');

          // Try to restore session using persisted refresh token
          try {
            await Supabase.instance.client.auth.setSession(
              currentSession!.refreshToken.toString(),
            );
          } catch (e) {
            print('Error restoring session: $e');
          }
        }

        // If still no session, try refreshing
        if (Supabase.instance.client.auth.currentSession == null ||
            Supabase.instance.client.auth.currentSession!.isExpired) {
          try {
            await Supabase.instance.client.auth.refreshSession();
          } catch (e) {
            print('Error refreshing session: $e');
            // Don't immediately redirect to login, try to finish this workflow first
          }
        }

        // If payment was successful, continue regardless of session state
        if (paymentResult == true) {
          // Refresh the fees and payment history
          try {
            await _loadUserFees();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pembayaran berjaya!'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            print('Error after successful payment: $e');
            // Even if there's an error loading fees, the payment was successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pembayaran berjaya, tetapi gagal untuk mengemaskini yuran.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to create bill. Please try again later.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _refreshPaymentData() async {
    try {
      setState(() {
        isProcessing.value = true;
      });

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null) {
        // Create a list of futures to execute in parallel
        final futures = [
          // Refresh fee data
          feeController.fetchYuranTertunggak(currentUserId),

          // Refresh payment history
          paymentController.fetchPaymentsByUserId(currentUserId),
        ];

        // Wait for all refreshes to complete
        await Future.wait(futures);

        // Set default fee if available
        if (feeController.yuranTertunggak.isNotEmpty) {
          setState(() {
            selectedFeeId =
                feeController.yuranTertunggak.first.feeId.toString();
            textAmountController.text = feeController
                .yuranTertunggak
                .first
                .feeAmount
                .toStringAsFixed(2);
          });
        } else {
          setState(() {
            selectedFeeId = null;
            textAmountController.text = "0.00";
          });
        }

        // Show success feedback
        Get.snackbar(
          'Refreshed',
          'Payment data updated successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
          icon: Icon(Icons.check_circle, color: Colors.green.shade800),
        );
      }
    } catch (error) {
      print('Error refreshing payment data: $error');
      Get.snackbar(
        'Refresh Failed',
        'Please check your connection and try again',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        icon: Icon(Icons.error, color: Colors.red.shade800),
      );
    } finally {
      setState(() {
        isProcessing.value = false;
      });
    }
  }
}
