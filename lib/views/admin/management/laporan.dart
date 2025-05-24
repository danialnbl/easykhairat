import 'dart:html' as html;
import 'dart:typed_data';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/controllers/family_controller.dart';
import 'package:moon_design/moon_design.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final userController = Get.put(UserController());
  final paymentController = Get.put(PaymentController());
  final tuntutanController = Get.put(TuntutanController());
  final familyController = Get.put(FamilyController());

  final RxString selectedDataType = 'Users'.obs;
  final RxString primaryType = 'Users'.obs;
  final RxString secondaryType = 'Payments'.obs;

  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await userController.fetchUsers();
    await paymentController.fetchPayments();
    await tuntutanController.fetchTuntutan();
    await familyController.fetchFamilyMembers();
    isLoading.value = false;
  }

  List<Map<String, dynamic>> getCurrentData() {
    // Filter data based on search if needed
    final searchTerm = searchController.text.toLowerCase();

    switch (selectedDataType.value) {
      case 'Users':
        return userController.users
            .where(
              (u) =>
                  searchTerm.isEmpty ||
                  u.userName.toLowerCase().contains(searchTerm) ||
                  u.userEmail.toLowerCase().contains(searchTerm) ||
                  u.userIdentification.toLowerCase().contains(searchTerm),
            )
            .map(
              (u) => {
                'ID': u.userId ?? '',
                'Name': u.userName,
                'IC': u.userIdentification,
                'Email': u.userEmail,
                'Type': u.userType,
                'Date': u.userCreatedAt.toString().split(' ').first,
              },
            )
            .toList();
      case 'Payments':
        return paymentController.payments
            .where(
              (p) =>
                  searchTerm.isEmpty ||
                  p.paymentDescription.toLowerCase().contains(searchTerm) ||
                  (p.paymentType?.toLowerCase() ?? '').contains(searchTerm),
            )
            .map(
              (p) => {
                'ID': p.paymentId ?? '',
                'User ID': p.userId ?? '',
                'Value': p.paymentValue,
                'Desc': p.paymentDescription,
                'Type': p.paymentType ?? '',
                'Date': p.paymentCreatedAt.toString().split(' ').first,
              },
            )
            .toList();
      case 'Claims':
        return tuntutanController.tuntutanList
            .where(
              (c) =>
                  searchTerm.isEmpty ||
                  c.claimOverallStatus.toLowerCase().contains(searchTerm) ||
                  (c.claimType?.toLowerCase() ?? '').contains(searchTerm),
            )
            .map(
              (c) => {
                'ID': c.claimId ?? '',
                'User ID': c.userId ?? '',
                'Status': c.claimOverallStatus,
                'Type': c.claimType ?? '',
                'Date': c.claimCreatedAt.toString().split(' ').first,
              },
            )
            .toList();
      case 'Family':
        return familyController.familyMembers
            .where(
              (f) =>
                  searchTerm.isEmpty ||
                  f.familymemberName.toLowerCase().contains(searchTerm) ||
                  f.familymemberRelationship.toLowerCase().contains(searchTerm),
            )
            .map(
              (f) => {
                'ID': f.familyId ?? '',
                'User ID': f.userId,
                'Name': f.familymemberName,
                'IC': f.familymemberIdentification,
                'Relation': f.familymemberRelationship,
                'Date': f.familyCreatedAt.toString().split(' ').first,
              },
            )
            .toList();
      default:
        return [];
    }
  }

  List<String> getCurrentColumns() {
    final data = getCurrentData();
    if (data.isEmpty) return [];
    return data.first.keys.toList();
  }

  List<Map<String, dynamic>> getCombinedData() {
    final primary = primaryType.value;
    final secondary = secondaryType.value;

    // Get lists
    List<Map<String, dynamic>> primaryList = [];
    List<Map<String, dynamic>> secondaryList = [];

    switch (primary) {
      case 'Users':
        primaryList =
            userController.users
                .map(
                  (u) => {
                    'User ID': u.userId ?? '',
                    'Name': u.userName,
                    'Email': u.userEmail,
                    'Type': u.userType,
                  },
                )
                .toList();
        break;
      case 'Payments':
        primaryList =
            paymentController.payments
                .map(
                  (p) => {
                    'User ID': p.userId ?? '',
                    'Payment Value': p.paymentValue,
                    'Payment Desc': p.paymentDescription,
                  },
                )
                .toList();
        break;
      // Add other cases...
    }

    switch (secondary) {
      case 'Users':
        secondaryList =
            userController.users
                .map(
                  (u) => {
                    'User ID': u.userId ?? '',
                    'Name2': u.userName,
                    'Email2': u.userEmail,
                    'Type2': u.userType,
                  },
                )
                .toList();
        break;
      case 'Payments':
        secondaryList =
            paymentController.payments
                .map(
                  (p) => {
                    'User ID': p.userId ?? '',
                    'Payment Value2': p.paymentValue,
                    'Payment Desc2': p.paymentDescription,
                  },
                )
                .toList();
        break;
      // Add other cases...
    }

    // Combine by 'User ID'
    List<Map<String, dynamic>> combined = [];
    for (var p in primaryList) {
      final match = secondaryList.firstWhereOrNull(
        (s) => s['User ID'] == p['User ID'],
      );
      combined.add({...p, ...?match});
    }
    return combined;
  }

  List<String> getCombinedColumns() {
    final data = getCombinedData();
    if (data.isEmpty) return [];
    return data.first.keys.toList();
  }

  Future<void> exportToExcel() async {
    isLoading.value = true;

    final data = getCurrentData();
    final columns = getCurrentColumns();
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    // Header
    for (int i = 0; i < columns.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(columns[i]);
    }
    // Data
    for (int row = 0; row < data.length; row++) {
      for (int col = 0; col < columns.length; col++) {
        sheet
            .getRangeByIndex(row + 2, col + 1)
            .setText('${data[row][columns[col]]}');
      }
    }
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final blob = html.Blob([
      bytes,
    ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', '${selectedDataType.value}_report.xlsx')
          ..click();
    html.Url.revokeObjectUrl(url);

    isLoading.value = false;
  }

  Future<void> exportToPDF() async {
    isLoading.value = true;

    final data = getCurrentData();
    final columns = getCurrentColumns();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Table.fromTextArray(
              headers: columns,
              data:
                  data
                      .map((row) => columns.map((c) => '${row[c]}').toList())
                      .toList(),
            ),
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', '${selectedDataType.value}_report.pdf')
          ..click();
    html.Url.revokeObjectUrl(url);

    isLoading.value = false;
  }

  // Enhanced search widget similar to manage_announce
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
              "Search & Filter Reports",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            // Report search
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
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search in reports...",
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
            // Data type filter
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => DropdownButton<String>(
                  value: selectedDataType.value,
                  underline: SizedBox(),
                  items:
                      ['Users', 'Payments', 'Claims', 'Family']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedDataType.value = value;
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton(
              onPressed: fetchAllData,
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
                child: Text("Refresh"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Export options card
  Widget _buildExportOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.file_download, color: Colors.green),
            SizedBox(width: 8),
            Text(
              "Export Options",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Export to PDF'),
                    onPressed: exportToPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.grid_on, color: Colors.white),
                    label: const Text('Export to Excel'),
                    onPressed: exportToExcel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the report data table card
  Widget _buildReportDataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${selectedDataType.value} Report Data",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () =>
                      isLoading.value
                          ? Container(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            "${getCurrentData().length} records found",
                            style: TextStyle(color: Colors.grey),
                          ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = getCurrentData();
                final columns = getCurrentColumns();

                if (data.isEmpty) {
                  return Center(
                    child: Text(
                      "No data found for ${selectedDataType.value}.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Create a nicely styled table
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.blue.shade100,
                      ),
                      dataRowColor: MaterialStateProperty.all(Colors.white),
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      columns:
                          columns
                              .map(
                                (column) => DataColumn(
                                  label: Text(
                                    column,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      rows:
                          data
                              .map(
                                (row) => DataRow(
                                  cells:
                                      columns
                                          .map(
                                            (column) => DataCell(
                                              Text('${row[column] ?? "N/A"}'),
                                            ),
                                          )
                                          .toList(),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
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
            AppHeader(title: "Laporan", notificationCount: 0),
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
                        label: const Text("Home"),
                        onTap: () => Get.toNamed('/adminMain'),
                      ),
                      MoonBreadcrumbItem(label: Text("Management")),
                      const MoonBreadcrumbItem(label: Text("Laporan")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildExportOptions(),
            const SizedBox(height: 16),
            Expanded(child: _buildReportDataCard()),
          ],
        ),
      ),
    );
  }
}
