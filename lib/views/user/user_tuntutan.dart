import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/claimLineModel.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserTuntutanPage extends StatefulWidget {
  final int claimId;

  const UserTuntutanPage({Key? key, required this.claimId}) : super(key: key);

  @override
  _UserTuntutanPageState createState() => _UserTuntutanPageState();
}

class _UserTuntutanPageState extends State<UserTuntutanPage> {
  final TuntutanController tuntutanController = Get.put(TuntutanController());
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );
  final supabase = Supabase.instance.client;

  // Active claim variables
  ClaimModel? activeClaim;
  bool isLoadingActiveClaim = true;

  @override
  void initState() {
    super.initState();
    _loadClaimDetails();
  }

  // Load specific claim details
  Future<void> _loadClaimDetails() async {
    setState(() {
      isLoadingActiveClaim = true;
    });

    try {
      final response =
          await supabase
              .from('claims')
              .select()
              .eq('claim_id', widget.claimId)
              .single();

      setState(() {
        activeClaim = ClaimModel.fromJson(response);
        claimLineController.getClaimLinesByClaimId(widget.claimId);
      });
    } catch (e) {
      print('Error loading claim details: $e');
      Get.snackbar(
        'Error',
        'Failed to load claim details',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() {
        isLoadingActiveClaim = false;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      appBar: AppBar(
        title: Text('Maklumat Tuntutan'),
        backgroundColor: MoonColors.light.bulma,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadClaimDetails(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isLoadingActiveClaim
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : activeClaim != null
                    ? _buildActiveClaimView()
                    : Center(child: Text('Tuntutan tidak dijumpai')),
          ),
        ),
      ),
    );
  }

  // Widget for displaying active claim details
  Widget _buildActiveClaimView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tuntutan #${activeClaim!.claimId}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(activeClaim!.claimOverallStatus),
                  ],
                ),
                Divider(),
                SizedBox(height: 8),
                _buildInfoRow(
                  'Tarikh Tuntutan:',
                  formatDate(activeClaim!.claimCreatedAt),
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  'Jenis Tuntutan:',
                  activeClaim!.claimType ?? 'Tidak dinyatakan',
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),

        // Claim line items section
        Text(
          'Butiran Tuntutan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Obx(() {
          if (claimLineController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (claimLineController.claimLineListByClaimId.isEmpty) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tiada butiran tuntutan',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddClaimLineDialog(),
                        icon: Icon(Icons.add),
                        label: Text('Tambah Butiran'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MoonColors.light.bulma,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: claimLineController.claimLineListByClaimId.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final item =
                        claimLineController.claimLineListByClaimId[index];
                    return ListTile(
                      title: Text(
                        item.claimLineReason,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                formatDate(item.claimLineCreatedAt),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        'RM ${item.claimLineTotalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: MoonColors.light.bulma,
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Keseluruhan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RM ${_calculateTotal().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: MoonColors.light.bulma,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeClaim!.claimOverallStatus.toLowerCase() ==
                    'dalam proses')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddClaimLineDialog(),
                      icon: Icon(Icons.add),
                      label: Text('Tambah Butiran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoonColors.light.bulma,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        SizedBox(height: 40),

        // Help section
        Card(
          color: Colors.amber.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.amber.shade800),
                    SizedBox(width: 8),
                    Text(
                      'Perlukan bantuan?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Sila hubungi pentadbir khairat atau tekan butang bantuan di bawah untuk mendapatkan maklumat lanjut tentang tuntutan.',
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Show support dialog
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: MoonColors.light.bulma,
                            ),
                            SizedBox(width: 10),
                            Text('Contact Support'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: MoonColors.light.bulma
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.phone,
                                  color: MoonColors.light.bulma,
                                ),
                              ),
                              title: Text('Call Admin'),
                              subtitle: Text('012-345-6789'),
                              onTap: () {
                                // Implement call functionality
                                Get.back();
                              },
                            ),
                            Divider(),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: MoonColors.light.bulma
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.email,
                                  color: MoonColors.light.bulma,
                                ),
                              ),
                              title: Text('Email'),
                              subtitle: Text('support@easykhairat.com'),
                              onTap: () {
                                // Implement email functionality
                                Get.back();
                              },
                            ),
                          ],
                        ),
                        actions: [
                          MoonButton(
                            onTap: () => Get.back(),
                            backgroundColor: Colors.grey[200],
                            textColor: Colors.black87,
                            label: Text("Close"),
                            borderRadius: BorderRadius.circular(50),
                            buttonSize: MoonButtonSize.md,
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.support_agent),
                  label: Text('Dapatkan Bantuan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to display status chips with appropriate colors
  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'lulus':
        chipColor = Colors.green;
        break;
      case 'gagal':
        chipColor = Colors.red;
        break;
      case 'dalam proses':
      default:
        chipColor = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget to display information rows
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: TextStyle(color: Colors.grey[700])),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Show dialog to add a new claim line
  void _showAddClaimLineDialog() {
    final reasonController = TextEditingController();
    final amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Tambah Butiran Tuntutan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Contoh: Kos pengkebumian',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah (RM)',
                  hintText: 'Contoh: 500.00',
                  border: OutlineInputBorder(),
                  prefixText: 'RM ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty ||
                  amountController.text.isEmpty) {
                Get.snackbar('Error', 'Sila lengkapkan semua maklumat');
                return;
              }

              try {
                double amount = double.parse(amountController.text);

                final newClaimLine = ClaimLineModel(
                  claimId: activeClaim!.claimId,
                  claimLineReason: reasonController.text,
                  claimLineTotalPrice: amount,
                  claimLineCreatedAt: DateTime.now(),
                  claimLineUpdatedAt: DateTime.now(),
                );

                await claimLineController.addClaimLine(newClaimLine);
                Get.back();

                Get.snackbar(
                  'Success',
                  'Butiran tuntutan telah ditambah',
                  backgroundColor: Colors.green.shade100,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Sila masukkan jumlah yang sah',
                  backgroundColor: Colors.red.shade100,
                );
              }
            },
            child: Text('Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MoonColors.light.bulma,
            ),
          ),
        ],
      ),
    );
  }

  // Calculate total claim amount
  double _calculateTotal() {
    double total = 0;
    for (var item in claimLineController.claimLineListByClaimId) {
      total += item.claimLineTotalPrice;
    }
    return total;
  }
}
