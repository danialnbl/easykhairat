import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/models/feeModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class ManageFee extends StatefulWidget {
  const ManageFee({Key? key}) : super(key: key);

  @override
  State<ManageFee> createState() => _ManageFeeState();
}

class _ManageFeeState extends State<ManageFee> {
  final FeeController feeController = Get.put(FeeController());
  final NavigationController navigationController =
      Get.find<NavigationController>();

  TextEditingController searchController = TextEditingController();
  RxString selectedFilter = 'Semua'.obs;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  Future<void> _loadFees() async {
    if (feeController.yuranGeneral.isEmpty) {
      await feeController.fetchFees();
    }
  }

  // Filter fees based on search text and selected year
  List<FeeModel> getFilteredFees() {
    return feeController.yuranGeneral.where((fee) {
      bool matchesSearch =
          searchController.text.isEmpty ||
          fee.feeDescription.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      bool matchesFilter =
          selectedFilter.value == 'Semua' ||
          (selectedFilter.value == fee.feeDue.year.toString());

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Get unique years for filtering
  List<String> getYearFilters() {
    Set<String> years = {'Semua'};
    for (var fee in feeController.yuranGeneral) {
      years.add(fee.feeDue.year.toString());
    }
    return years.toList()..sort();
  }

  // Enhanced search widget with refresh button
  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Cari & Tapis Yuran",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            // Description search
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.description, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Cari mengikut tajuk...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            // Year filter dropdown
            Obx(() {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: selectedFilter.value,
                  underline: SizedBox(),
                  items:
                      getYearFilters()
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedFilter.value = value;
                    }
                  },
                ),
              );
            }),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Refresh fee data
                  await feeController.fetchFees();

                  // Close loading dialog
                  Get.back();

                  // Show success message
                  Get.snackbar(
                    'Berjaya',
                    'Senarai yuran telah dikemaskini',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                } catch (e) {
                  // Close loading dialog
                  Get.back();

                  // Show error message
                  Get.snackbar(
                    'Ralat',
                    'Gagal memuat semula data: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                }
              },
              label: Text("Muat Semula"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(width: 16),
            // Add new fee button
            ElevatedButton.icon(
              onPressed: () {
                navigationController.changeIndex(
                  10,
                ); // Navigate to add fee screen
              },
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text("Tetapkan Yuran"),
              style: ElevatedButton.styleFrom(
                backgroundColor: MoonColors.light.roshi,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the fees table
  Widget _buildFeesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Senarai Yuran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (feeController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                var filteredFees = getFilteredFees();

                if (filteredFees.isEmpty) {
                  return Center(
                    child: Text(
                      "Tiada yuran yang ditemui.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFees.length,
                  itemBuilder: (context, index) {
                    final fee = filteredFees[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          fee.feeDescription,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Tahun ${fee.feeDue.year} • RM ${fee.feeAmount.toStringAsFixed(2)}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${fee.feeCreatedAt.day}/${fee.feeCreatedAt.month}/${fee.feeCreatedAt.year}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                feeController.setFee(fee);
                                navigationController.changeIndex(13);
                              },
                              tooltip: "Lihat Maklumat",
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Sahkan Pemadaman'),
                                    content: const Text(
                                      'Adakah anda pasti mahu memadamkan yuran ini?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          feeController.deleteFee(
                                            fee.feeId ?? 0,
                                          );
                                          Get.back();
                                        },
                                        child: const Text('Padam'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: "Padam Yuran",
                            ),
                          ],
                        ),
                        onTap: () {
                          feeController.setFee(fee);
                          navigationController.changeIndex(13);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced refresh button that updates fee data
  Widget _buildRefreshButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed:
            feeController.isLoading.value
                ? null
                : () async {
                  // Show loading indicator
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  try {
                    // Refresh fee data
                    await feeController.fetchFees();

                    // Close loading dialog
                    Get.back();

                    // Show success message
                    Get.snackbar(
                      'Berjaya',
                      'Senarai yuran telah dikemaskini',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  } catch (e) {
                    // Close loading dialog
                    Get.back();

                    // Show error message
                    Get.snackbar(
                      'Ralat',
                      'Gagal memuat semula data: $e',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
        icon:
            feeController.isLoading.value
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.refresh),
        label: Text(
          feeController.isLoading.value ? 'Memuat semula...' : 'Muat Semula',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: "Tetapan Yuran",
              notificationCount: 3,
              onNotificationPressed: () {
                // Handle notification click
              },
            ),
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
                      MoonBreadcrumbItem(label: Text("Tetapan Yuran")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildFeesList()),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}
