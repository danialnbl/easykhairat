import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/models/feeModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormYuran extends StatefulWidget {
  @override
  _FormYuranState createState() => _FormYuranState();
}

class _FormYuranState extends State<FormYuran> {
  final NavigationController navController = Get.put(NavigationController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tajukYuranController = TextEditingController();
  final TextEditingController _jumlahYuranController = TextEditingController();
  String? selectedUserId;
  String? selectedJenisYuran;

  final TextEditingController _tarikhBayaranController =
      TextEditingController();

  final UserController userController = Get.put(UserController());

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
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
              AppHeader(title: "Maklumat Yuran", notificationCount: 3),
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
                          onTap: () => navController.selectedIndex.value = 0,
                        ),
                        MoonBreadcrumbItem(label: Text("Kewangan")),
                        MoonBreadcrumbItem(
                          label: Text("Tetapan Yuran"),
                          onTap: () => navController.selectedIndex.value = 3,
                        ),
                        MoonBreadcrumbItem(label: Text("Tambah Yuran")),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Section: Form
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
                                "Maklumat Yuran Baru",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Obx(() {
                                if (userController.isLoading.value) {
                                  return CircularProgressIndicator();
                                } else if (userController.normalusers.isEmpty) {
                                  return Text('Tiada pengguna tersedia.');
                                } else {
                                  return DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Pilih Pengguna',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        userController.normalusers
                                            .map(
                                              (user) => DropdownMenuItem(
                                                value:
                                                    user.userId, // Assuming 'id' is a String property of User
                                                child: Text(
                                                  user.userName,
                                                ), // Assuming 'name' is a property of User
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      // Handle user selection
                                      selectedUserId = value;
                                    },
                                  );
                                }
                              }),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _tajukYuranController,
                                decoration: InputDecoration(
                                  labelText: '* Tajuk Yuran',
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _jumlahYuranController,
                                decoration: InputDecoration(
                                  labelText: '* Jumlah Yuran (RM)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Wajib diisi';
                                  final num? parsed = num.tryParse(value);
                                  if (parsed == null || parsed <= 0)
                                    return 'Jumlah mesti lebih dari 0';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _tarikhBayaranController,
                                readOnly: true,
                                onTap:
                                    () => _selectDate(
                                      context,
                                      _tarikhBayaranController,
                                    ),
                                decoration: InputDecoration(
                                  labelText: '* Tarikh Bayaran',
                                  hintText: 'DD-MM-YYYY',
                                  border: OutlineInputBorder(),
                                ),
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: '* Jenis Yuran',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Bulanan',
                                    child: Text('Bulanan'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Tahunan',
                                    child: Text('Tahunan'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Lain-lain',
                                    child: Text('Lain-lain'),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle dropdown change
                                  selectedJenisYuran = value;
                                },
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final feeController = Get.put(
                                          FeeController(),
                                        );

                                        try {
                                          String? adminId =
                                              Supabase
                                                  .instance
                                                  .client
                                                  .auth
                                                  .currentUser
                                                  ?.id;
                                          if (adminId == null) {
                                            Get.snackbar(
                                              'Ralat',
                                              'ID admin tidak sah.',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }

                                          final fee = FeeModel(
                                            // feeId is excluded entirely
                                            feeDescription:
                                                _tajukYuranController.text,
                                            feeAmount: double.parse(
                                              _jumlahYuranController.text,
                                            ),
                                            feeDue: DateFormat(
                                              'dd-MM-yyyy',
                                            ).parse(
                                              _tarikhBayaranController.text,
                                            ),
                                            feeType: selectedJenisYuran!,
                                            feeStatus: 'Tertunggak',
                                            userId: selectedUserId,
                                            adminId: int.parse(
                                              userController.adminLogged.value,
                                            ),
                                            feeCreatedAt: DateTime.now(),
                                            feeUpdatedAt: DateTime.now(),
                                          );

                                          await feeController.addFee(fee);

                                          _formKey.currentState!.reset();
                                          _tajukYuranController.clear();
                                          _jumlahYuranController.clear();
                                          _tarikhBayaranController.clear();
                                          selectedUserId = null;
                                          selectedJenisYuran = null;
                                        } catch (e) {
                                          print("Error saving fee: $e");
                                          Get.snackbar(
                                            'Ralat',
                                            'Terjadi ralat semasa menyimpan data.',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        }
                                      } else {
                                        Get.snackbar(
                                          'Ralat',
                                          'Sila isi semua ruangan yang wajib.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },

                                    child: Text("Simpan"),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _formKey.currentState!.reset();
                                      _tajukYuranController.clear();
                                      _jumlahYuranController.clear();
                                      _tarikhBayaranController.clear();
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
                  // Right Section: Guidelines
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
                              "Panduan",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text("• Ruangan bertanda * wajib diisi."),
                            const SizedBox(height: 8),
                            Text("• Pastikan jumlah yuran adalah tepat."),
                            const SizedBox(height: 8),
                            Text("• Tarikh bayaran perlu diisi dengan betul."),
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
