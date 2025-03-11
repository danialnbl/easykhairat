import 'package:easykhairat/controllers/toyyibpay_service.dart';
import 'package:easykhairat/views/user/fpxPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class UserPayment extends StatefulWidget {
  const UserPayment({Key? key}) : super(key: key);

  @override
  _UserPaymentState createState() => _UserPaymentState();
}

class _UserPaymentState extends State<UserPayment> {
  final TextEditingController paymentController = TextEditingController(
    text: "0.00",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Account',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Card(
                                color: MoonColors.light.goku,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pakej 1 Tahun',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '8a1b120c-c4a7-448b-9f78-047b5080eb1d',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Total Due (RM):',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pay before 11 March 2025',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      MoonTextInput(
                                        controller: paymentController,
                                        textInputSize: MoonTextInputSize.md,
                                        obscureText: false,
                                        backgroundColor: MoonColors.light.goku,
                                        cursorColor: MoonColors.light.trunks,
                                        initialValue: "0.00",
                                        textColor: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Minimum payment is RM2.00',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: MoonFilledButton(
                                  borderRadius: BorderRadius.circular(50),
                                  buttonSize: MoonButtonSize.md,
                                  onTap: () async {
                                    try {
                                      final toyyibPayService =
                                          ToyyibPayService();

                                      // Remove any "RM" prefix and trim spaces
                                      String paymentText =
                                          paymentController.text
                                              .replaceAll(RegExp(r'[^\d.]'), '')
                                              .trim();

                                      // Convert cleaned string to double
                                      double? payment = double.tryParse(
                                        paymentText,
                                      );

                                      if (payment == null || payment < 2.0) {
                                        throw Exception(
                                          'Minimum payment amount is RM2.00',
                                        );
                                      }

                                      // Generate the bill
                                      String?
                                      billCode = await toyyibPayService.createBill(
                                        billTitle: 'Booking Payment',
                                        billDescription:
                                            'Payment for booking ID: 123456',
                                        billAmount: (payment * 100)
                                            .toStringAsFixed(0),
                                        userEmail: "danialnabil0208@gmail.com",
                                        userPhone: "01123138061",
                                        categoryCode:
                                            'r53xplxf', // Replace with your category code
                                      );

                                      if (billCode != null) {
                                        // Navigate to the payment page
                                        Get.to(
                                          () => PaymentPage(billCode: billCode),
                                        );
                                      } else {
                                        throw Exception(
                                          'Failed to create bill. Please try again later.',
                                        );
                                      }
                                    } catch (error) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Payment failed: $error',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  label: const Text("MAKE PAYMENT"),
                                  isFullWidth: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
