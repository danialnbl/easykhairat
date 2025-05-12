import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';

class TuntutanAhli extends StatefulWidget {
  const TuntutanAhli({super.key});

  @override
  TuntutanAhliState createState() => TuntutanAhliState();
}

class TuntutanAhliState extends State<TuntutanAhli> {
  final TuntutanController claimController = Get.put(TuntutanController());
  final NavigationController navController = Get.put(NavigationController());

  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String claimType = "Kematian";
  String claimStatus = "Dalam Proses";

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
              AppHeader(title: "Tuntutan Khairat", notificationCount: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      visibleItemCount: 5,
                      items: [
                        MoonBreadcrumbItem(
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: Text("Kewangan")),
                        MoonBreadcrumbItem(
                          label: Text("Proses Tuntutan"),
                          onTap: () => navController.selectedIndex.value = 5,
                        ),
                        MoonBreadcrumbItem(label: Text("Tuntutan Khairat")),
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
                                "Maklumat Tuntutan ${navController.getUser()?.userName}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: amountController,
                                decoration: InputDecoration(
                                  labelText: "Jumlah Tuntutan (RM)",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sila isi jumlah tuntutan';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Tarikh Tuntutan",
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
                                value: claimType,
                                items: [
                                  DropdownMenuItem(
                                    value: "Kematian",
                                    child: Text("Kematian"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Kemalangan",
                                    child: Text("Kemalangan"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Lain-lain",
                                    child: Text("Lain-lain"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    claimType = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Jenis Tuntutan",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: reasonController,
                                decoration: InputDecoration(
                                  labelText: "Sebab Tuntutan",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     if (_formKey.currentState!.validate()) {
                                  //       final claim = ClaimModel(
                                  //         claimValue: double.parse(
                                  //           amountController.text,
                                  //         ),
                                  //         claimDescription:
                                  //             reasonController.text,
                                  //         claimType: claimType,
                                  //         claimStatus: claimStatus,
                                  //         claimCreatedAt: DateTime.now(),
                                  //         claimUpdatedAt: DateTime.now(),
                                  //         userId:
                                  //             navController.getUser()?.userId,
                                  //         additionalNotes: noteController.text,
                                  //       );

                                  //       claimController
                                  //           .addClaim(claim)
                                  //           .then((_) {
                                  //             _formKey.currentState?.reset();
                                  //             amountController.clear();
                                  //             dateController.clear();
                                  //             reasonController.clear();
                                  //             noteController.clear();
                                  //             setState(() {
                                  //               claimType = "Kematian";
                                  //             });

                                  //             Get.snackbar(
                                  //               'Berjaya',
                                  //               'Tuntutan telah dihantar.',
                                  //             );
                                  //           })
                                  //           .catchError((error) {
                                  //             Get.snackbar(
                                  //               'Ralat',
                                  //               'Gagal menghantar tuntutan.',
                                  //             );
                                  //             print("Error: $error");
                                  //                                                 }
                                  //   },
                                  //   child: Text("Hantar"),
                                  // ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _formKey.currentState?.reset();
                                      amountController.clear();
                                      dateController.clear();
                                      reasonController.clear();
                                      noteController.clear();
                                      setState(() {
                                        claimType = "Kematian";
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
                              "Sejarah Tuntutan",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              // if (claimController.claims.isEmpty) {
                              //   return Text("Tiada sejarah tuntutan.");
                              // }
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                // child: ListView.builder(
                                //   shrinkWrap: true,
                                //   physics: NeverScrollableScrollPhysics(),
                                //   itemCount: claimController.claims.length,
                                //   itemBuilder: (context, index) {
                                //     final claim = claimController.claims[index];
                                //     return ListTile(
                                //       title: Text(claim.claimType),
                                //       subtitle: Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             formatDate(claim.claimCreatedAt),
                                //           ),
                                //           Text("Status: ${claim.claimStatus}"),
                                //         ],
                                //       ),
                                //       trailing: Text(
                                //         "RM ${claim.claimValue.toStringAsFixed(2)}",
                                //       ),
                                //     );
                                //   },
                                // ),
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
