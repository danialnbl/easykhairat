import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/models/feeModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class ManageFee extends StatelessWidget {
  ManageFee({Key? key}) : super(key: key);

  final FeeController feeController = Get.put(FeeController());

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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MoonButton(
                  leading: const Icon(
                    MoonIcons.files_add_text_16_light,
                    color: Colors.white,
                  ),
                  buttonSize: MoonButtonSize.md,
                  onTap: () {
                    // Navigate to add fee form
                    Get.toNamed(
                      '/addFee',
                    ); // Assuming you have a route set up for adding fees
                  },
                  label: const Text(
                    'Tetapkan Yuran Baru',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: MoonColors.light.roshi,
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

  Widget _buildTable() {
    return Obx(() {
      if (feeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (feeController.fees.isEmpty) {
        return const Center(child: Text("Tiada Yuran Dijumpai."));
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          children: [
            _buildTableHeader(),
            ...feeController.fees.map((fee) => _buildTableRow(fee)).toList(),
          ],
        ),
      );
    });
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: MoonColors.light.roshi),
      children: const [
        _TableHeaderCell('Tajuk'),
        _TableHeaderCell('Untuk Tahun'),
        _TableHeaderCell('Jumlah (RM)'),
        _TableHeaderCell('Jana Pada'),
        _TableHeaderCell('Actions'),
      ],
    );
  }

  TableRow _buildTableRow(FeeModel fee) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _TableCell(fee.feeDescription),
        _TableCell(fee.feeDue.year.toString()),
        _TableCell("RM ${fee.feeAmount.toStringAsFixed(2)}"),
        _TableCell(
          "${fee.feeCreatedAt.day}/${fee.feeCreatedAt.month}/${fee.feeCreatedAt.year}",
        ),

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  // Navigate to view fee details
                  Get.toNamed('/viewFee', arguments: fee.feeId);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // Navigate to edit fee form
                  Get.toNamed('/editFee', arguments: fee.feeId);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  feeController.deleteFee(fee.feeId);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
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
