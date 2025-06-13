import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/controllers/family_controller.dart';
import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:moon_design/moon_design.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

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
  final FeeController feeController = Get.put(FeeController());
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );

  final RxString selectedDataType = 'Pengguna'.obs;
  final RxString primaryType = 'Pengguna'.obs;
  final RxString secondaryType = 'Pembayaran'.obs;

  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxDouble totalOutstandingFees = 0.0.obs;

  // Add these variables at the top of your _LaporanPageState class
  final RxString selectedMonth = 'Semua'.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  @override
  void initState() {
    super.initState();
    fetchAllData();
    calculateTotalOutstandingFees();
    paymentController.fetchTotalPayments();
    // Replace fetchTotalClaimLine with fetchTotalApprovedClaimLine
    claimLineController.fetchTotalApprovedClaimLine();
  }

  // Add this method to calculate total outstanding fees
  void calculateTotalOutstandingFees() async {
    try {
      double total =
          await feeController.calculateTotalOutstandingFeesForAllUsers();
      totalOutstandingFees.value = total;
    } catch (e) {
      print("Error calculating total outstanding fees: $e");
    }
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await userController.fetchUsers();
    await paymentController.fetchPayments();
    await tuntutanController.fetchTuntutan();
    await familyController.fetchFamilyMembers();
    isLoading.value = false;
  }

  // Add this method to get all months
  List<String> getAllMonths() {
    return [
      'Semua',
      'Januari',
      'Februari',
      'Mac',
      'April',
      'Mei',
      'Jun',
      'Julai',
      'Ogos',
      'September',
      'Oktober',
      'November',
      'Disember',
    ];
  }

  // Add this method to get the month number from name
  int getMonthNumber(String monthName) {
    final months = {
      'Januari': 1,
      'Februari': 2,
      'Mac': 3,
      'April': 4,
      'Mei': 5,
      'Jun': 6,
      'Julai': 7,
      'Ogos': 8,
      'September': 9,
      'Oktober': 10,
      'November': 11,
      'Disember': 12,
    };
    return months[monthName] ?? 0;
  }

  // Modify the getCurrentData() method in the payment case to include user names instead of IDs
  List<Map<String, dynamic>> getCurrentData() {
    // Filter data based on search if needed
    final searchTerm = searchController.text.toLowerCase();

    switch (selectedDataType.value) {
      case 'Pengguna':
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
                'Nama': u.userName,
                'No. Kad Pengenalan': u.userIdentification,
                'Emel': u.userEmail,
                'Jenis': u.userType,
                'Tarikh': formatDate(u.userCreatedAt.toString()),
              },
            )
            .toList();
      case 'Pembayaran':
        return paymentController.payments
            .where((p) {
              // First apply text search filter
              bool matchesSearch =
                  searchTerm.isEmpty ||
                  p.paymentDescription.toLowerCase().contains(searchTerm) ||
                  (p.paymentType?.toLowerCase() ?? '').contains(searchTerm);

              // Then apply month filter if a specific month is selected
              bool matchesMonth = true;
              if (selectedMonth.value != 'Semua') {
                final paymentDate = DateTime.parse(
                  p.paymentCreatedAt.toString(),
                );
                final monthNum = getMonthNumber(selectedMonth.value);
                matchesMonth =
                    paymentDate.month == monthNum &&
                    paymentDate.year == selectedYear.value;
              }

              return matchesSearch && matchesMonth;
            })
            .map((p) {
              // Find the user name for this payment
              final user = userController.users.firstWhereOrNull(
                (u) => u.userId == p.userId,
              );
              final userName = user?.userName ?? 'Pengguna tidak dijumpai';

              return {
                'ID': p.paymentId ?? '',
                'Nama': userName, // Display user name instead of ID
                'Nilai': p.paymentValue,
                'Keterangan': p.paymentDescription,
                'Jenis': p.paymentType ?? '',
                'Tarikh': p.paymentCreatedAt.toString().split(' ').first,
              };
            })
            .toList();
      case 'Tuntutan':
        return tuntutanController.tuntutanList
            .where((c) {
              // First apply text search filter
              bool matchesSearch =
                  searchTerm.isEmpty ||
                  c.claimOverallStatus.toLowerCase().contains(searchTerm) ||
                  (c.claimType?.toLowerCase() ?? '').contains(searchTerm);

              // Then apply month filter if a specific month is selected
              bool matchesMonth = true;
              if (selectedMonth.value != 'Semua') {
                final claimDate = DateTime.parse(c.claimCreatedAt.toString());
                final monthNum = getMonthNumber(selectedMonth.value);
                matchesMonth =
                    claimDate.month == monthNum &&
                    claimDate.year == selectedYear.value;
              }

              return matchesSearch && matchesMonth;
            })
            .map((c) {
              // Find the user name for this claim
              final user = userController.users.firstWhereOrNull(
                (u) => u.userId == c.userId,
              );
              final userName = user?.userName ?? 'Pengguna tidak dijumpai';

              return {
                'ID': c.claimId ?? '',
                'Nama': userName, // Display user name instead of ID
                'Status': c.claimOverallStatus,
                'Jenis': c.claimType ?? '',
                'Tarikh': c.claimCreatedAt.toString().split(' ').first,
              };
            })
            .toList();
      case 'Keluarga':
        return familyController.familyMembers
            .where(
              (f) =>
                  searchTerm.isEmpty ||
                  f.familymemberName.toLowerCase().contains(searchTerm) ||
                  f.familymemberRelationship.toLowerCase().contains(searchTerm),
            )
            .map((f) {
              // Find the user name for this family member
              final user = userController.users.firstWhereOrNull(
                (u) => u.userId == f.userId,
              );
              final userName = user?.userName ?? 'Pengguna tidak dijumpai';

              return {
                'ID': f.familyId ?? '',
                'Nama Pengguna': userName, // Display user name
                'Nama Ahli Keluarga': f.familymemberName,
                'No. Kad Pengenalan': f.familymemberIdentification,
                'Hubungan': f.familymemberRelationship,
                'Tarikh': f.familyCreatedAt.toString().split(' ').first,
              };
            })
            .toList();
      case 'Kewangan':
        return getFinancialData()
            .where(
              (f) =>
                  searchTerm.isEmpty ||
                  f['Kategori'].toString().toLowerCase().contains(searchTerm) ||
                  f['Keterangan'].toString().toLowerCase().contains(searchTerm),
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
      case 'Pengguna':
        primaryList =
            userController.users
                .map(
                  (u) => {
                    'ID Pengguna': u.userId ?? '',
                    'Nama': u.userName,
                    'Emel': u.userEmail,
                    'Jenis': u.userType,
                  },
                )
                .toList();
        break;
      case 'Pembayaran':
        primaryList =
            paymentController.payments
                .map(
                  (p) => {
                    'ID Pengguna': p.userId ?? '',
                    'Nilai Pembayaran': p.paymentValue,
                    'Keterangan Pembayaran': p.paymentDescription,
                  },
                )
                .toList();
        break;
      // Add other cases...
    }

    switch (secondary) {
      case 'Pengguna':
        secondaryList =
            userController.users
                .map(
                  (u) => {
                    'ID Pengguna': u.userId ?? '',
                    'Nama2': u.userName,
                    'Emel2': u.userEmail,
                    'Jenis2': u.userType,
                  },
                )
                .toList();
        break;
      case 'Pembayaran':
        secondaryList =
            paymentController.payments
                .map(
                  (p) => {
                    'ID Pengguna': p.userId ?? '',
                    'Nilai Pembayaran2': p.paymentValue,
                    'Keterangan Pembayaran2': p.paymentDescription,
                  },
                )
                .toList();
        break;
      // Add other cases...
    }

    // Combine by 'ID Pengguna'
    List<Map<String, dynamic>> combined = [];
    for (var p in primaryList) {
      final match = secondaryList.firstWhereOrNull(
        (s) => s['ID Pengguna'] == p['ID Pengguna'],
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

    // Add logo
    final ByteData logoData = await rootBundle.load(
      'assets/images/easyKhairatLogo.png',
    );
    final List<int> logoBytes = logoData.buffer.asUint8List();
    final int logoRowIndex = 1;
    final int logoColIndex = 1;
    final xlsio.Picture picture = sheet.pictures.addStream(
      logoRowIndex,
      logoColIndex,
      logoBytes,
    );
    picture.width = 100;
    picture.height = 50;

    // Add title row (now at row 1, but with offset for the logo)
    final titleRange = sheet.getRangeByIndex(1, 3, 1, columns.length + 2);
    titleRange.setText('Laporan ${selectedDataType.value} - EasyKhairat');
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 14;
    titleRange.cellStyle.hAlign = xlsio.HAlignType.center;
    titleRange.merge();

    // Add date subtitle row
    final dateRange = sheet.getRangeByIndex(2, 3, 2, columns.length + 2);
    final currentDate = formatDate(DateTime.now().toString());
    dateRange.setText('Tarikh: $currentDate');
    dateRange.cellStyle.fontSize = 12;
    dateRange.cellStyle.hAlign = xlsio.HAlignType.center;
    dateRange.merge();

    // Header (now at row 4)
    for (int i = 0; i < columns.length; i++) {
      sheet.getRangeByIndex(4, i + 1).setText(columns[i]);
      sheet.getRangeByIndex(4, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(4, i + 1).cellStyle.backColor = '#D3E5F5';
    }

    // Data (now starting at row 5)
    for (int row = 0; row < data.length; row++) {
      for (int col = 0; col < columns.length; col++) {
        // Format dates in the data
        var cellValue = data[row][columns[col]];
        if (columns[col].toLowerCase().contains('tarikh') &&
            cellValue != null) {
          cellValue = formatDate(cellValue.toString());
        }
        sheet.getRangeByIndex(row + 5, col + 1).setText('$cellValue');
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
          ..setAttribute('download', 'Laporan_${selectedDataType.value}.xlsx')
          ..click();
    html.Url.revokeObjectUrl(url);

    isLoading.value = false;
  }

  Future<void> exportToPDF() async {
    isLoading.value = true;

    final data = getCurrentData();
    final columns = getCurrentColumns();
    final pdf = pw.Document();

    // Load the logo image
    final ByteData logoData = await rootBundle.load(
      'assets/images/easyKhairatLogo.png',
    );
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Add logo and title in a row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logoImage, width: 100, height: 50),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Add title
                          pw.Text(
                            'Laporan ${selectedDataType.value} - EasyKhairat',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          // Add date
                          pw.Text(
                            'Tarikh: ${formatDate(DateTime.now().toString())}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 100), // Balance the layout
                  ],
                ),
                pw.SizedBox(height: 20),
                // Add data table
                pw.Table.fromTextArray(
                  headers: columns,
                  data:
                      data
                          .map(
                            (row) =>
                                columns.map((c) {
                                  var cellValue = row[c];
                                  // Format dates in the data
                                  if (c.toLowerCase().contains('tarikh') &&
                                      cellValue != null) {
                                    cellValue = formatDate(
                                      cellValue.toString(),
                                    );
                                  }
                                  return '$cellValue';
                                }).toList(),
                          )
                          .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  cellAlignments: {
                    for (var i = 0; i < columns.length; i++)
                      i: pw.Alignment.centerLeft,
                  },
                ),
              ],
            ),
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'Laporan_${selectedDataType.value}.pdf')
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Carian & Tapis Laporan",
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
                              hintText: "Cari dalam laporan...",
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
                          [
                                'Pengguna',
                                'Pembayaran',
                                'Tuntutan',
                                'Keluarga',
                                'Kewangan',
                              ]
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
                    child: Text("Muat Semula"),
                  ),
                ),
              ],
            ),
            // Month filter row (only shown for payment and claim)
            Obx(() {
              if (selectedDataType.value == 'Pembayaran' ||
                  selectedDataType.value == 'Tuntutan') {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Tapis Mengikut Bulan:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 16),
                      // Month filter
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Obx(
                          () => DropdownButton<String>(
                            value: selectedMonth.value,
                            underline: SizedBox(),
                            items:
                                getAllMonths()
                                    .map(
                                      (month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(month),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedMonth.value = value;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Year filter
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Obx(
                          () => DropdownButton<int>(
                            value: selectedYear.value,
                            underline: SizedBox(),
                            items: [
                              for (
                                int year = DateTime.now().year;
                                year >= DateTime.now().year - 5;
                                year--
                              )
                                DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                selectedYear.value = value;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),
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
              "Pilihan Eksport",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Eksport ke PDF'),
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
                    label: const Text('Eksport ke Excel'),
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
                  "Data Laporan ${selectedDataType.value}",
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
                            "${getCurrentData().length} rekod dijumpai",
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
                      "Tiada data dijumpai untuk ${selectedDataType.value}.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Use LayoutBuilder to make table responsive to available space
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      // Make it take the full available height
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.6,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth:
                                  constraints.maxWidth -
                                  32, // Account for padding
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.blue.shade100,
                              ),
                              dataRowColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                width: 1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              headingRowHeight:
                                  50, // Increase header row height
                              dataRowMinHeight:
                                  50, // Increase minimum row height
                              dataRowMaxHeight:
                                  70, // Increase maximum row height
                              columnSpacing:
                                  24, // Add more space between columns
                              horizontalMargin: 16, // Add horizontal margin
                              showBottomBorder:
                                  true, // Ensure bottom border is visible
                              columns:
                                  columns
                                      .map(
                                        (column) => DataColumn(
                                          label: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              column,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15, // Larger font
                                              ),
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Text(
                                                          '${row[column] ?? "Tiada"}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
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

  // New financial summary card
  Widget _buildFinancialSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Ringkasan Kewangan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Masukkan dalam Eksport'),
                  onPressed: () {
                    // Add a new option to the dropdown
                    if (!selectedDataType.value.contains('Kewangan')) {
                      selectedDataType.value = 'Kewangan';
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialInfoItem(
                    title: 'Kutipan Yuran',
                    value:
                        'RM ${paymentController.totalPayments.value.toStringAsFixed(2)}',
                    icon: Icons.money,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildFinancialInfoItem(
                    title: 'Jumlah Tunggakan',
                    value:
                        'RM ${totalOutstandingFees.value.toStringAsFixed(2)}',
                    icon: Icons.account_balance,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFinancialInfoItem(
                    title: 'Tuntutan Ahli (Diluluskan)',
                    value:
                        'RM ${claimLineController.totalClaimLine.value.toStringAsFixed(2)}',
                    icon: Icons.money_off,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildFinancialInfoItem(
                    title: 'Baki Bersih',
                    value:
                        'RM ${(paymentController.totalPayments.value - claimLineController.totalClaimLine.value).toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfoItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> getFinancialData() {
    return [
      {
        'Kategori': 'Kutipan Yuran',
        'Nilai (RM)': paymentController.totalPayments.value.toStringAsFixed(2),
        'Keterangan': 'Jumlah pembayaran yuran oleh ahli',
      },
      {
        'Kategori': 'Jumlah Tunggakan',
        'Nilai (RM)': totalOutstandingFees.value.toStringAsFixed(2),
        'Keterangan': 'Jumlah tunggakan yuran ahli',
      },
      {
        'Kategori': 'Tuntutan Ahli (Diluluskan)',
        'Nilai (RM)': claimLineController.totalClaimLine.value.toStringAsFixed(
          2,
        ),
        'Keterangan': 'Jumlah tuntutan khairat yang diluluskan',
      },
      {
        'Kategori': 'Baki Bersih',
        'Nilai (RM)': (paymentController.totalPayments.value -
                claimLineController.totalClaimLine.value)
            .toStringAsFixed(2),
        'Keterangan': 'Baki bersih kewangan (kutipan - tuntutan diluluskan)',
      },
    ];
  }

  // Add this helper function to your _LaporanPageState class
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return dateString; // Return the original string if parsing fails
    }
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
            const SizedBox(height: 4), // Further reduced spacing
            SizedBox(
              width: double.infinity,
              child: Card(
                color: MoonColors.light.goku,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Further reduced padding
                  child: MoonBreadcrumb(
                    items: [
                      MoonBreadcrumbItem(
                        label: const Text("Laman Utama"),
                        onTap: () => Get.toNamed('/adminMain'),
                      ),
                      MoonBreadcrumbItem(label: Text("Pengurusan")),
                      const MoonBreadcrumbItem(label: Text("Laporan")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4), // Further reduced spacing
            _buildSearchBar(),
            const SizedBox(height: 4), // Further reduced spacing
            _buildExportOptions(),
            const SizedBox(height: 4), // Further reduced spacing
            _buildFinancialSummaryCard(),
            const SizedBox(height: 4), // Further reduced spacing
            Expanded(
              flex: 10, // Increased from 3 to 5
              child: _buildReportDataCard(),
            ),
          ],
        ),
      ),
    );
  }
}
