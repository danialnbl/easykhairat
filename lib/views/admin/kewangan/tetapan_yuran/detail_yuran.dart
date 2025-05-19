import 'package:easykhairat/models/feeModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailYuran extends StatefulWidget {
  const DetailYuran({super.key});

  @override
  DetailYuranState createState() => DetailYuranState();
}

class DetailYuranState extends State<DetailYuran> {
  final NavigationController navController = Get.put(NavigationController());
  final FeeController feeController = Get.put(FeeController());
  final _viewFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController namaYuranController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String yuranType = "Yuran Tahunan";

  @override
  void initState() {
    super.initState();
    // Load fee details if available
    final fee = feeController.getFee();
    if (fee != null) {
      namaYuranController.text = fee.feeDescription;
      amountController.text = fee.feeAmount.toString();
      descriptionController.text = fee.feeDescription;
      yuranType = fee.feeType;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    namaYuranController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
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
              AppHeader(title: "Tetapan Yuran", notificationCount: 3),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      visibleItemCount: 4,
                      items: [
                        MoonBreadcrumbItem(
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: Text("Kewangan")),
                        MoonBreadcrumbItem(
                          label: Text("Tetapan Yuran"),
                          onTap: () => navController.selectedIndex.value = 3,
                        ),
                        MoonBreadcrumbItem(label: Text("Detail Yuran")),
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
                          key: _viewFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Maklumat Yuran",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      "ID Yuran",
                                      "${feeController.getFee()?.feeId ?? '-'}",
                                    ),
                                    _buildInfoRow(
                                      "Nama Yuran",
                                      "${feeController.getFee()?.feeDescription ?? '-'}",
                                    ),
                                    _buildInfoRow(
                                      "Jenis Yuran",
                                      "${feeController.getFee()?.feeType ?? '-'}",
                                    ),
                                    _buildInfoRow(
                                      "Jumlah (RM)",
                                      "${feeController.getFee()?.feeAmount.toString() ?? '-'}",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
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
                        child: Form(
                          key: _editFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Edit Maklumat Yuran",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: namaYuranController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Yuran',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sila masukkan nama yuran';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: yuranType,
                                decoration: const InputDecoration(
                                  labelText: 'Jenis Yuran',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    ['Yuran Tahunan', 'Yuran Bulanan']
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    yuranType = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Jumlah (RM)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sila masukkan jumlah';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Sila masukkan nilai yang sah';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () async {
                                      print(
                                        "Button pressed - initial",
                                      ); // Debug print

                                      if (_editFormKey.currentState!
                                          .validate()) {
                                        print(
                                          "Form validated successfully",
                                        ); // Debug print

                                        try {
                                          final existingFee =
                                              feeController.getFee();
                                          print(
                                            "Existing fee: ${existingFee?.feeId}",
                                          ); // Debug print

                                          final updatedFee = FeeModel(
                                            feeId: existingFee?.feeId,
                                            feeDescription:
                                                namaYuranController.text,
                                            feeDue: DateTime.now().add(
                                              const Duration(days: 30),
                                            ),
                                            feeType: yuranType,
                                            feeCreatedAt:
                                                existingFee?.feeCreatedAt ??
                                                DateTime.now(),
                                            feeUpdatedAt: DateTime.now(),
                                            adminId:
                                                1, // Replace with actual admin ID
                                            feeAmount: double.parse(
                                              amountController.text,
                                            ),
                                            feeStatus: 'Active',
                                          );

                                          print(
                                            "Updating fee with data: ${updatedFee.toString()}",
                                          ); // Debug print

                                          if (existingFee != null) {
                                            await feeController.updateFee(
                                              updatedFee,
                                            ); // Use await here
                                            print("Fee updated successfully");
                                            Get.snackbar(
                                              'Berjaya',
                                              'Maklumat yuran telah dikemaskini.',
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                              snackPosition: SnackPosition.TOP,
                                            );
                                            await Future.delayed(
                                              const Duration(seconds: 1),
                                            ); // Small delay before navigation
                                            navController.selectedIndex.value =
                                                3;
                                          } else {
                                            await feeController.addFee(
                                              updatedFee,
                                            ); // Use await here
                                            print("New fee added successfully");
                                            Get.snackbar(
                                              'Berjaya',
                                              'Maklumat yuran telah ditambah.',
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                              snackPosition: SnackPosition.TOP,
                                            );
                                            await Future.delayed(
                                              const Duration(seconds: 1),
                                            ); // Small delay before navigation
                                            navController.selectedIndex.value =
                                                3;
                                          }
                                        } catch (e) {
                                          print(
                                            "Error occurred: $e",
                                          ); // Debug print
                                          Get.snackbar(
                                            'Error',
                                            'Gagal menyimpan maklumat yuran: $e',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      feeController.getFee() != null
                                          ? 'Kemaskini'
                                          : 'Simpan',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('Batal'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
