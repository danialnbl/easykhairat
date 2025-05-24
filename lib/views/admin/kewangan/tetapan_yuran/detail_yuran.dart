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
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

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

  // Replace the direct update with confirmation
  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Pengesahan'),
        content: const Text(
          'Adakah anda pasti untuk mengemaskini maklumat yuran ini?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Get.back();
              _saveFee();
            },
            child: const Text(
              'Ya, Kemaskini',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Add a new method for saving the fee
  Future<void> _saveFee() async {
    setState(() => _isLoading = true);
    try {
      final existingFee = feeController.getFee();

      final updatedFee = FeeModel(
        feeId: existingFee?.feeId,
        feeDescription:
            namaYuranController.text.isEmpty
                ? existingFee?.feeDescription ?? ''
                : namaYuranController.text,
        feeDue:
            existingFee?.feeDue ?? DateTime.now().add(const Duration(days: 30)),
        feeType: yuranType,
        feeCreatedAt: existingFee?.feeCreatedAt ?? DateTime.now(),
        feeUpdatedAt: DateTime.now(),
        adminId: existingFee?.adminId ?? 1,
        feeAmount:
            amountController.text.isEmpty
                ? existingFee?.feeAmount ?? 0.0
                : double.parse(amountController.text),
      );

      if (existingFee != null) {
        await feeController.updateFee(updatedFee);
        setState(() => _isLoading = false);
        Get.snackbar(
          'Berjaya',
          'Maklumat yuran telah dikemaskini.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        await Future.delayed(const Duration(seconds: 1));
        navController.selectedIndex.value = 3;
      } else {
        await feeController.addFee(updatedFee);
        setState(() => _isLoading = false);
        Get.snackbar(
          'Berjaya',
          'Maklumat yuran telah ditambah.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        await Future.delayed(const Duration(seconds: 1));
        navController.selectedIndex.value = 3;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Gagal menyimpan maklumat yuran: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Perubahan Belum Disimpan'),
          content: const Text(
            'Anda mempunyai perubahan yang belum disimpan. Adakah anda pasti ingin keluar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Maklumat Yuran",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
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
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_document,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Edit Maklumat Yuran",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Maklumat Yuran",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          indent: 16,
                                          endIndent: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextFormField(
                                  controller: namaYuranController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Yuran',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                  onChanged: (value) => _markAsChanged(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Sila masukkan nama yuran';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Replace the dropdown with this enhanced version
                                DropdownButtonFormField<String>(
                                  value: yuranType,
                                  decoration: const InputDecoration(
                                    labelText: 'Jenis Yuran',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category),
                                    helperText:
                                        'Jenis yuran menentukan kekerapan pembayaran',
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
                                      _markAsChanged();
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Jumlah (RM)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.payments),
                                    prefixText: 'RM ',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
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
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () {
                                                if (_editFormKey.currentState!
                                                    .validate()) {
                                                  _showConfirmationDialog();
                                                }
                                              },
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Text(
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
      ),
    );
  }
}
