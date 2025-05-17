import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/claimLineModel.dart';
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
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String claimType = "Ahli Sendiri";
  String claimStatus = "Dalam Proses";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    claimController.fetchTuntutan();

    // Initialize with current claim data or defaults
    final tuntutan = claimController.getTuntutan();
    selectedDate = tuntutan?.claimCreatedAt ?? DateTime.now();
    claimType = tuntutan?.claimType ?? "Ahli Sendiri";
    claimStatus = tuntutan?.claimOverallStatus ?? "Dalam Proses";

    dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final tuntutan = claimController.getTuntutan();
    if (tuntutan?.claimOverallStatus != null) {
      claimStatus = tuntutan!.claimOverallStatus;
    }
    if (tuntutan?.claimType != null) {
      claimType = tuntutan!.claimType.toString();
    }

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
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Tarikh Tuntutan",
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                      dateController.text = DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(pickedDate);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: claimType,
                                items: [
                                  DropdownMenuItem(
                                    value: "Ahli Sendiri",
                                    child: Text("Ahli Sendiri"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Ahli Keluarga",
                                    child: Text("Ahli Keluarga"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    claimType = value!;
                                    print(
                                      "Changed claim type to: $claimType",
                                    ); // Debug print
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Jenis Tuntutan",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: claimStatus,
                                items: [
                                  DropdownMenuItem(
                                    value: "Dalam Proses",
                                    child: Text("Dalam Proses"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Lulus",
                                    child: Text("Lulus"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Gagal",
                                    child: Text("Gagal"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    claimStatus = value!;
                                    print(
                                      "Changed claim status to: $claimStatus",
                                    ); // Debug print
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Status Tuntutan",
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
                                        print(
                                          "Submitting - Type: $claimType, Status: $claimStatus",
                                        ); // Debug print

                                        final claim = ClaimModel(
                                          claimId:
                                              claimController
                                                  .getTuntutan()
                                                  ?.claimId,
                                          claimOverallStatus: claimStatus,
                                          claimCreatedAt: selectedDate,
                                          claimUpdatedAt: DateTime.now(),
                                          userId:
                                              navController.getUser()?.userId,
                                          claimType: claimType,
                                        );

                                        claimController
                                            .updateTuntutan(claim)
                                            .then((_) {
                                              // Show success message
                                              Get.snackbar(
                                                'Berjaya',
                                                'Tuntutan telah dikemaskini',
                                                snackPosition:
                                                    SnackPosition.TOP,
                                              );
                                            });
                                      }
                                    },
                                    child: Text("Kemaskini"),
                                  ),
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
                              "Senarai Tuntutan",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (claimLineController.isLoading.value) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (claimLineController
                                  .claimLineListByClaimId
                                  .isEmpty) {
                                return Text("Tiada senarai tuntutan.");
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
                                      claimLineController
                                          .claimLineListByClaimId
                                          .length,
                                  itemBuilder: (context, index) {
                                    final claim =
                                        claimLineController
                                            .claimLineListByClaimId[index];
                                    return ListTile(
                                      title: Text(
                                        'Tuntutan: ${claim.claimLineReason}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Tarikh: ${formatDate(claim.claimLineCreatedAt)}',
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Jumlah: RM${claim.claimLineTotalPrice.toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              claimLineController.setClaimLine(
                                                claim,
                                              );

                                              final editAmountController =
                                                  TextEditingController(
                                                    text:
                                                        claim
                                                            .claimLineTotalPrice
                                                            .toString(),
                                                  );
                                              final editReasonController =
                                                  TextEditingController(
                                                    text: claim.claimLineReason,
                                                  );

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: Text(
                                                        'Edit Tuntutan',
                                                      ),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  editAmountController,
                                                              decoration: InputDecoration(
                                                                labelText:
                                                                    'Jumlah (RM)',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                            ),
                                                            SizedBox(
                                                              height: 16,
                                                            ),
                                                            TextField(
                                                              controller:
                                                                  editReasonController,
                                                              decoration:
                                                                  InputDecoration(
                                                                    labelText:
                                                                        'Sebab',
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: Text('Batal'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            final updatedClaim = ClaimLineModel(
                                                              claimLineId:
                                                                  claim
                                                                      .claimLineId,
                                                              claimId:
                                                                  claim.claimId,
                                                              claimLineTotalPrice:
                                                                  double.parse(
                                                                    editAmountController
                                                                        .text,
                                                                  ),
                                                              claimLineReason:
                                                                  editReasonController
                                                                      .text,
                                                              claimLineCreatedAt:
                                                                  claim
                                                                      .claimLineCreatedAt,
                                                              claimLineUpdatedAt:
                                                                  DateTime.now(),
                                                            );
                                                            claimLineController
                                                                .updateClaimLine(
                                                                  updatedClaim,
                                                                );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text('Simpan'),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Padam Tuntutan',
                                                    ),
                                                    content: Text(
                                                      'Adakah anda pasti ingin memadam tuntutan ini?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text('Batal'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (claim
                                                                  .claimLineId !=
                                                              null) {
                                                            claimLineController
                                                                .deleteClaimLine(
                                                                  claim,
                                                                );
                                                          }
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text('Padam'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final newAmountController =
                                        TextEditingController();
                                    final newReasonController =
                                        TextEditingController();

                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Tambah Tuntutan Baru'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        newReasonController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Sebab',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  TextField(
                                                    controller:
                                                        newAmountController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Jumlah (RM)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final newClaimLine =
                                                      ClaimLineModel(
                                                        claimId:
                                                            claimController
                                                                .getTuntutan()
                                                                ?.claimId,
                                                        claimLineTotalPrice:
                                                            double.parse(
                                                              newAmountController
                                                                  .text,
                                                            ),
                                                        claimLineReason:
                                                            newReasonController
                                                                .text,
                                                        claimLineCreatedAt:
                                                            DateTime.now(),
                                                        claimLineUpdatedAt:
                                                            DateTime.now(),
                                                      );
                                                  claimLineController
                                                      .addClaimLine(
                                                        newClaimLine,
                                                      );
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Tambah'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Tambah Tuntutan'),
                                ),
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
