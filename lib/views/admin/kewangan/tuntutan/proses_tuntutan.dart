import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
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
  final NavigationController navController = Get.put(NavigationController());
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );
  RxString selectedFilter = 'Semua Tuntutan'.obs;
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController claimIdSearchController = TextEditingController();

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
          (claim.user?.userName?.toLowerCase() ?? '').contains(
            nameSearchController.text.toLowerCase(),
          );

      bool matchesClaimId =
          claimIdSearchController.text.isEmpty ||
          (claim.claimId?.toString() ?? '').contains(
            claimIdSearchController.text,
          );

      bool matchesFilter =
          selectedFilter.value == 'Semua Tuntutan' ||
          claim.claimOverallStatus.toLowerCase() ==
              selectedFilter.value.toLowerCase();

      return matchesName && matchesClaimId && matchesFilter;
    }).toList();
  }

  // Enhanced search widget similar to proses_yuran
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
              "Cari & Tapis Tuntutan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            // Name search
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
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: nameSearchController,
                        decoration: InputDecoration(
                          hintText: "Cari mengikut nama...",
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
            // Claim ID search
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
                    Icon(Icons.receipt, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: claimIdSearchController,
                        decoration: InputDecoration(
                          hintText: "Cari mengikut ID tuntutan...",
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
            // Filter dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => DropdownButton<String>(
                  value: selectedFilter.value,
                  underline: SizedBox(),
                  items:
                      ['Semua Tuntutan', 'Lulus', 'Dalam Proses', 'Gagal']
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
            ),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton(
              onPressed: () {
                tuntutanController.fetchTuntutan();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text("Muat Semula"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the table showing claims in card format similar to proses_yuran
  Widget _buildClaimsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Senarai Tuntutan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (tuntutanController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final filteredClaims = getFilteredClaims();

                if (filteredClaims.isEmpty) {
                  return Center(
                    child: Text(
                      "Tiada tuntutan yang ditemui.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredClaims.length,
                  itemBuilder: (context, index) {
                    final claim = filteredClaims[index];

                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.info_outline;

                    if (claim.claimOverallStatus == 'Dalam Proses') {
                      statusColor = Colors.orange;
                      statusIcon = Icons.pending_actions;
                    } else if (claim.claimOverallStatus == 'Lulus') {
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                    } else if (claim.claimOverallStatus == 'Gagal') {
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.receipt_long, color: Colors.blue),
                        ),
                        title: Text(
                          "ID: ${claim.claimId} - ${claim.user?.userName ?? 'N/A'}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Dibuat pada: ${formatDate(claim.claimCreatedAt)}",
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    claim.claimOverallStatus,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                if (claim.user != null) {
                                  claimLineController.getClaimLinesByClaimId(
                                    claim.claimId!,
                                  );
                                  tuntutanController.setTuntutan(claim);
                                  navController.setUser(claim.user!);
                                  navController.changeIndex(12);
                                }
                              },
                              tooltip: "Lihat Tuntutan",
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _showDeleteConfirmation(claim),
                              tooltip: "Padam Tuntutan",
                            ),
                          ],
                        ),
                        onTap: () {
                          if (claim.user != null) {
                            claimLineController.getClaimLinesByClaimId(
                              claim.claimId!,
                            );
                            tuntutanController.setTuntutan(claim);
                            navController.setUser(claim.user!);
                            navController.changeIndex(12);
                          }
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

  void _showDeleteConfirmation(ClaimModel claim) {
    Get.dialog(
      AlertDialog(
        title: Text('Padam Tuntutan'),
        content: Text(
          'Adakah anda pasti untuk memadam tuntutan ini?\n\n'
          'ID: ${claim.claimId}\n'
          'Pemohon: ${claim.user?.userName ?? "N/A"}\n'
          'Status: ${claim.claimOverallStatus}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              tuntutanController.deleteTuntutan(claim.claimId!);
            },
            child: Text('Padam'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
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
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildClaimsTable()),
          ],
        ),
      ),
    );
  }
}
