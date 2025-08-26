import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final primaryColor = Color(0xFF2BAAAD);
final secondaryColor = Color(0xFF35C2C5);
final accentColor = Color(0xFF1D7F82);
final lightAccentColor = Color(0xFFE0F7F8);
final backgroundColor = Color(0xFFF5FCFC);

class UserTuntutanPage extends StatefulWidget {
  final int claimId;

  const UserTuntutanPage({Key? key, required this.claimId}) : super(key: key);

  @override
  _UserTuntutanPageState createState() => _UserTuntutanPageState();
}

class _UserTuntutanPageState extends State<UserTuntutanPage> {
  final TuntutanController tuntutanController = Get.put(TuntutanController());
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
      // First get the claim details
      final response =
          await supabase
              .from('claims')
              .select()
              .eq('claim_id', widget.claimId)
              .single();

      // Set the active claim
      final claim = ClaimModel.fromJson(response);

      // Only update state after both operations complete successfully
      if (mounted) {
        setState(() {
          activeClaim = claim;
        });
      }
    } catch (e) {
      print('Error loading claim details: $e');
      Get.snackbar(
        'Error',
        'Failed to load claim details',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingActiveClaim = false;
        });
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Maklumat Tuntutan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadClaimDetails(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isLoadingActiveClaim
                    ? _buildLoadingView()
                    : activeClaim != null
                    ? _buildActiveClaimView()
                    : _buildErrorView(),
          ),
        ),
      ),
    );
  }

  // Widget for displaying loading state
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 20),
          Text(
            'Memuat turun maklumat tuntutan...',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Widget for displaying error state
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80),
          Icon(Icons.error_outline_rounded, size: 70, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Tiada maklumat tuntutan ditemui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sila cuba lagi atau hubungi pentadbir',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadClaimDetails,
            icon: Icon(Icons.refresh),
            label: Text('Cuba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(160, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: primaryColor.withOpacity(0.5),
            ),
          ),
        ],
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

        // Certificate Image Section
        if (activeClaim!.claimCertificateUrl != null &&
            activeClaim!.claimCertificateUrl!.isNotEmpty) ...{
          Text(
            'Sijil Kematian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        // Show full screen image
                        Get.dialog(
                          Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBar(
                                  title: Text('Sijil Kematian'),
                                  backgroundColor: primaryColor,
                                  leading: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                                Flexible(
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.network(
                                      activeClaim!.claimCertificateUrl!,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                            color: primaryColor,
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 64,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Gagal memuat gambar',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 300),
                        width: double.infinity,
                        child: Image.network(
                          activeClaim!.claimCertificateUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Gagal memuat gambar sijil',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Open image in fullscreen
                          Get.dialog(
                            Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBar(
                                    title: Text('Sijil Kematian'),
                                    backgroundColor: primaryColor,
                                    leading: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                  Flexible(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        activeClaim!.claimCertificateUrl!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.fullscreen),
                        label: Text('Lihat Penuh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        },

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
        SizedBox(height: 24),

        // Cancel Claim Button - only show for claims in process
        if (activeClaim!.claimOverallStatus.toLowerCase() ==
            'dalam proses') ...[
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelClaimConfirmation(),
              icon: Icon(Icons.cancel_outlined),
              label: Text(
                'Batalkan Tuntutan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],

        SizedBox(height: 16),
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
      case 'dibatalkan':
        chipColor = Colors.grey;
        textColor = Colors.black87; // Use black text for cancelled status
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

  // Show confirmation dialog for canceling the claim
  void _showCancelClaimConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Batalkan Tuntutan?',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda pasti mahu membatalkan tuntutan ini?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Tindakan ini tidak boleh diubah dan semua maklumat tuntutan akan dipadamkan.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tidak', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              _cancelClaim();
            },
            child: Text(
              'Ya, Batalkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add method to handle claim cancellation
  Future<void> _cancelClaim() async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator(color: primaryColor)),
        barrierDismissible: false,
      );

      // Update the claim status in the database
      await supabase
          .from('claims')
          .update({'claim_overallStatus': 'Dibatalkan'})
          .eq('claim_id', activeClaim!.claimId.toString());

      // Close loading dialog
      Get.back();

      // Refresh claim details
      await _loadClaimDetails();

      // Show success message
      Get.snackbar(
        'Berjaya',
        'Tuntutan telah dibatalkan',
        backgroundColor: Colors.green.shade100,
        duration: Duration(seconds: 3),
      );

      // Navigate back after a short delay
      Future.delayed(Duration(seconds: 1), () {
        Get.back(); // Return to previous screen
      });
    } catch (e) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen!) {
        Get.back();
      }

      print('Error cancelling claim: $e');
      Get.snackbar(
        'Ralat',
        'Gagal membatalkan tuntutan. Sila cuba lagi.',
        backgroundColor: Colors.red.shade100,
        duration: Duration(seconds: 3),
      );
    }
  }
}
