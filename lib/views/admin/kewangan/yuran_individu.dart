import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/models/paymentModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';

class YuranIndividu extends StatefulWidget {
  const YuranIndividu({super.key});

  @override
  YuranIndividuState createState() => YuranIndividuState();
}

class YuranIndividuState extends State<YuranIndividu> {
  final FeeController feeController = Get.put(FeeController());
  final NavigationController navController = Get.put(NavigationController());
  final PaymentController paymentController = Get.put(PaymentController());

  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController receiptController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String paymentMethod = "Tunai";
  String? selectedInvoice;

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(title: "Bayaran Yuran", notificationCount: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      items: [
                        MoonBreadcrumbItem(
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: Text("Kewangan")),
                        MoonBreadcrumbItem(label: Text("Yuran Individu")),
                        MoonBreadcrumbItem(
                          label: Text("${navController.getUser()?.userName}"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Maklumat Yuran Ahli ${navController.getUser()?.userName}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: amountController,
                                decoration: InputDecoration(
                                  labelText: "Jumlah (RM)",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sila isi jumlah';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Tarikh Bayaran",
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (selectedDate != null) {
                                    dateController.text = DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(selectedDate);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: paymentMethod,
                                items: [
                                  DropdownMenuItem(
                                    value: "Tunai",
                                    child: Text("Tunai"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Lain-lain",
                                    child: Text("Lain-lain"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    paymentMethod = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Kaedah Pembayaran",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: receiptController,
                                decoration: InputDecoration(
                                  labelText: "Nombor Resit",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: noteController,
                                decoration: InputDecoration(
                                  labelText: "Nota Tambahan",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(() {
                                return DropdownButtonFormField<String>(
                                  value: selectedInvoice,
                                  items:
                                      feeController.yuranTertunggak.map((fee) {
                                        return DropdownMenuItem(
                                          value: fee.feeId.toString(),
                                          child: Text(fee.feeDescription),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedInvoice = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        feeController.yuranTertunggak == null
                                            ? "Tiada Bayaran Tertunggak"
                                            : "Bayaran",
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Create a new PaymentModel instance
                                        final payment = PaymentModel(
                                          paymentValue: double.parse(
                                            amountController.text,
                                          ),
                                          paymentDescription:
                                              noteController.text.isEmpty
                                                  ? "Bayaran Yuran"
                                                  : noteController.text,
                                          paymentCreatedAt: DateTime.now(),
                                          paymentUpdatedAt: DateTime.now(),
                                          feeId: int.parse(
                                            selectedInvoice ?? '0',
                                          ), // Ensure selectedInvoice is not null
                                          userId:
                                              navController.getUser()?.userId,
                                          paymentType: paymentMethod,
                                        );

                                        // Add the payment using the PaymentController
                                        paymentController
                                            .addPayment(payment)
                                            .then((_) {
                                              // Update the fee status to "Dibayar"
                                              feeController.updateFeeStatus(
                                                int.parse(selectedInvoice!),
                                                "Dibayar",
                                              );

                                              // Clear the form after successful submission
                                              _formKey.currentState?.reset();
                                              amountController.clear();
                                              dateController.clear();
                                              receiptController.clear();
                                              noteController.clear();
                                              setState(() {
                                                selectedInvoice = null;
                                                paymentMethod = "Tunai";
                                              });

                                              // Refresh the fee list
                                              feeController
                                                  .fetchYuranTertunggak(
                                                    navController
                                                            .getUser()
                                                            ?.userId
                                                            .toString() ??
                                                        "",
                                                  );

                                              // Show success message
                                              Get.snackbar(
                                                'Berjaya',
                                                'Bayaran telah disimpan.',
                                              );
                                            })
                                            .catchError((error) {
                                              // Show error message
                                              Get.snackbar(
                                                'Ralat',
                                                'Gagal menyimpan bayaran.',
                                              );
                                              print("Error: $error");
                                            });
                                      }
                                    },
                                    child: Text("Simpan"),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _formKey.currentState?.reset();
                                      amountController.clear();
                                      dateController.clear();
                                      receiptController.clear();
                                      noteController.clear();
                                      setState(() {
                                        selectedInvoice = null;
                                        paymentMethod = "Tunai";
                                      });
                                    },
                                    child: Text("Batal"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                  // Right Section: Account Transactions
                  Expanded(
                    flex: 3,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaksi Akaun",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text("Yuran Tertunggak"),
                            const SizedBox(height: 8),
                            Obx(() {
                              if (feeController.yuranTertunggak.isEmpty) {
                                return Text("Tiada yuran tertunggak.");
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      feeController.yuranTertunggak.length,
                                  itemBuilder: (context, index) {
                                    final fee =
                                        feeController.yuranTertunggak[index];
                                    return ListTile(
                                      title: Text(
                                        fee.feeDescription.toString(),
                                      ),
                                      subtitle: Text(
                                        formatDate(fee.feeCreatedAt),
                                      ),
                                      trailing: Text(
                                        "RM ${fee.feeAmount.toStringAsFixed(2)}",
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Text("Transaksi Bayaran dan Tuntutan"),
                            const SizedBox(height: 8),
                            Obx(() {
                              if (paymentController.payments.isEmpty) {
                                return Text("Tiada transaksi bayaran.");
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: paymentController.payments.length,
                                  itemBuilder: (context, index) {
                                    final payment =
                                        paymentController.payments[index];
                                    return ListTile(
                                      title: Text(
                                        payment.paymentDescription ??
                                            "Transaksi",
                                      ),
                                      subtitle: Text(
                                        formatDate(payment.paymentCreatedAt),
                                      ),
                                      trailing: Text(
                                        "RM ${payment.paymentValue.toStringAsFixed(2)}",
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
