import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
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
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      value: "Tunai",
                                      groupValue: paymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          paymentMethod = value!;
                                        });
                                      },
                                      title: Text("Tunai"),
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      value: "Lain-lain",
                                      groupValue: paymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          paymentMethod = value!;
                                        });
                                      },
                                      title: Text("Lain-lain"),
                                    ),
                                  ),
                                ],
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
                              DropdownButtonFormField<String>(
                                value: selectedInvoice,
                                items: [
                                  DropdownMenuItem(
                                    child: Text("Invois 1"),
                                    value: "1",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Invois 2"),
                                    value: "2",
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedInvoice = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Invois",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Submit action here
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
                              if (feeController.fees.isEmpty) {
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
                                  itemCount: feeController.fees.length,
                                  itemBuilder: (context, index) {
                                    final fee = feeController.fees[index];
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
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                ListTile(
                                  title: Text(
                                    "Tuntutan untuk Ahli yang meninggal",
                                  ),
                                  subtitle: Text("30 Oct 19"),
                                  trailing: Text("RM 1,000.00"),
                                ),
                                ListTile(
                                  title: Text("Bayaran Yuran Ahli"),
                                  subtitle: Text("02 Feb 22"),
                                  trailing: Text("RM 20.00"),
                                ),
                                // Add more items here
                              ],
                            ),
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
