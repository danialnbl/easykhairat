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

  @override
  void initState() {
    super.initState();
    userController.fetchUsers();
    paymentController.fetchPayments();
    tuntutanController.fetchTuntutan();
    familyController.fetchFamilyMembers();
  }

  List<Map<String, dynamic>> getCurrentData() {
    switch (selectedDataType.value) {
      case 'Users':
        return userController.users
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
  }

  Future<void> exportToPDF() async {
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
  }

  Widget buildTable() {
    final data = getCurrentData();
    final columns = getCurrentColumns();

    if (data.isEmpty) {
      return const Center(child: Text('No data found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: {
          for (int i = 0; i < columns.length; i++) i: const FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: MoonColors.light.roshi),
            children:
                columns
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          // Data rows
          ...data.map(
            (row) => TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children:
                  columns
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '${row[c]}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      )
                      .toList(),
            ),
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
                      const MoonBreadcrumbItem(label: Text("Laporan")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Obx(
                  () => DropdownButton<String>(
                    value: selectedDataType.value,
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download PDF'),
                  onPressed: exportToPDF,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.grid_on),
                  label: const Text('Download Excel'),
                  onPressed: exportToExcel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: Obx(() => buildTable())),
          ],
        ),
      ),
    );
  }
}
