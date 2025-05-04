import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProsesTuntutan extends StatefulWidget {
  const ProsesTuntutan({super.key});

  @override
  ProsesTuntutanState createState() => ProsesTuntutanState();
}

class ProsesTuntutanState extends State<ProsesTuntutan> {
  final TuntutanController tuntutanController = Get.put(TuntutanController());
  RxString selectedFilter = 'Semua Tuntutan'.obs;
  TextEditingController nameSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tuntutanController.fetchTuntutan();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  List<ClaimModel> getFilteredClaims() {
    return tuntutanController.tuntutanList.where((claim) {
      bool matchesName =
          nameSearchController.text.isEmpty ||
              claim.userId!.toLowerCase().contains(
                nameSearchController.text.toLowerCase(),
              ) ??
          false;

      bool matchesFilter =
          selectedFilter.value == 'Semua Tuntutan' ||
          claim.claimOverallStatus.toLowerCase() ==
              selectedFilter.value.toLowerCase();

      return matchesName && matchesFilter;
    }).toList();
  }

  void viewClaim(ClaimModel claim) {
    Get.dialog(
      AlertDialog(
        title: Text('Claim Details: ${claim.userId ?? "Unknown"}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Claim ID', claim.claimId?.toString() ?? 'N/A'),
              _detailRow('Status', claim.claimOverallStatus),
              _detailRow('Created At', formatDate(claim.claimCreatedAt)),
              _detailRow('Updated At', formatDate(claim.claimUpdatedAt)),
              _detailRow('Family ID', claim.familyId.toString()),
              _detailRow('Claim Type', claim.claimType ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Close'), onPressed: () => Get.back()),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Obx(() {
      final filteredClaims = getFilteredClaims();

      if (tuntutanController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (filteredClaims.isEmpty) {
        return const Center(child: Text('No claims found'));
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(2),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: MoonColors.light.roshi),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Claim ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'User ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Created At',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Claim Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ...filteredClaims.map((claim) {
              return TableRow(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      claim.claimId?.toString() ?? 'N/A',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      claim.userId ?? 'N/A',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      claim.claimOverallStatus,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      formatDate(claim.claimCreatedAt),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      claim.claimType ?? 'N/A',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.green,
                          ),
                          onPressed: () => viewClaim(claim),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      );
    });
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
            AppHeader(title: "Proses Tuntutan", notificationCount: 3),
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
                      MoonBreadcrumbItem(label: Text("Proses Tuntutan")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameSearchController,
                    decoration: InputDecoration(
                      hintText: "Search by User ID...",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<String>(
                    value: selectedFilter.value,
                    items:
                        ['Semua Tuntutan', 'Approved', 'Pending', 'Rejected']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedFilter.value = value;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }
}
