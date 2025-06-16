import 'dart:async';

import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:easykhairat/views/user/create_tuntutan.dart';
import 'package:easykhairat/views/user/user_tuntutan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final primaryColor = Color(0xFF2BAAAD);
final secondaryColor = Color(0xFF35C2C5);
final accentColor = Color(0xFF1D7F82);
final lightAccentColor = Color(0xFFE0F7F8);
final backgroundColor = Color(0xFFF5FCFC);

class ListTuntutanPage extends StatefulWidget {
  const ListTuntutanPage({Key? key}) : super(key: key);

  @override
  _ListTuntutanPageState createState() => _ListTuntutanPageState();
}

class _ListTuntutanPageState extends State<ListTuntutanPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = false;
  List<ClaimModel> _userClaims = [];
  bool _hasLoadedInitially = false;
  // Add a future to control the FutureBuilder properly
  late Future<List<ClaimModel>> _claimsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future
    _claimsFuture = _fetchUserTuntutan();
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Refresh data method - clearer separation of concerns
  void _refreshData() {
    setState(() {
      _userClaims = []; // Clear cache
      _hasLoadedInitially = false;
      _claimsFuture = _fetchUserTuntutan(isRefresh: true);
    });
  }

  // Fetch user's tuntutan list with improved error handling and caching
  Future<List<ClaimModel>> _fetchUserTuntutan({bool isRefresh = false}) async {
    // If we already have data and this isn't a forced refresh, return cached data
    if (_userClaims.isNotEmpty && _hasLoadedInitially && !isRefresh) {
      return _userClaims;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Add a small artificial delay when refreshing to ensure loading state is shown
      if (isRefresh) {
        await Future.delayed(Duration(milliseconds: 800));
      }

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          isLoading = false;
        });

        // Improved error display
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.person_off, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sila log masuk semula untuk melihat tuntutan anda',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'LOG MASUK',
              textColor: Colors.white,
              onPressed: () {
                // Add navigation to login page here
                // Get.offAll(() => LoginPage());
              },
            ),
          ),
        );

        return [];
      }

      // Add a timeout to prevent hanging forever
      final response = await supabase
          .from('claims')
          .select('*')
          .eq('user_id', userId)
          .order('claim_created_at', ascending: false)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Database request timed out');
            },
          );

      // Cache the results
      _userClaims =
          (response as List).map((data) => ClaimModel.fromJson(data)).toList();

      _hasLoadedInitially = true;

      setState(() {
        isLoading = false;
      });

      return _userClaims;
    } catch (e) {
      // Enhanced error handling
      print('Error fetching user tuntutan: $e');
      setState(() {
        isLoading = false;
      });

      // Show more specific error messages based on error type
      String errorMessage = 'Gagal memuat senarai tuntutan';
      if (e is TimeoutException) {
        errorMessage =
            'Sambungan ke pangkalan data terlalu lambat. Sila cuba lagi.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Tiada sambungan internet. Sila periksa sambungan anda.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'CUBA LAGI',
            textColor: Colors.white,
            onPressed: () {
              _refreshData();
            },
          ),
        ),
      );

      // Return cached data if available, otherwise empty list
      return _userClaims.isNotEmpty ? _userClaims : [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Senarai Tuntutan',
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
        onRefresh: () async {
          _refreshData();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Senarai tuntutan dikemaskini'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 1),
            ),
          );
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info card
                Card(
                  color: MoonColors.light.bulma.withOpacity(0.1),
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
                            Icon(
                              MoonIcons.generic_info_16_light,
                              color: MoonColors.light.bulma,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tuntutan Khairat Kematian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tuntutan ini adalah untuk ahli yang berdaftar di bawah khairat kematian. '
                          'Sila lengkapkan maklumat yang diperlukan dan lampirkan dokumen yang berkaitan.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // List of user's tuntutan
                _buildTuntutanList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => CreateTuntutanPage())?.then((_) {
            _refreshData();
          });
        },
        label: Text(
          'Buat Tuntutan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.add),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Build the list of user's tuntutan
  Widget _buildTuntutanList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Senarai Tuntutan Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Add refresh button
            if (_hasLoadedInitially)
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : IconButton(
                    icon: Icon(Icons.refresh, color: MoonColors.light.bulma),
                    onPressed: _refreshData,
                  ),
          ],
        ),
        FutureBuilder<List<ClaimModel>>(
          future: _claimsFuture,
          builder: (context, snapshot) {
            // Always show loading state when waiting or when there's an error
            if (snapshot.connectionState == ConnectionState.waiting ||
                isLoading ||
                (snapshot.hasError && _userClaims.isEmpty)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat senarai tuntutan...',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty state
            List<ClaimModel> claims = snapshot.data ?? _userClaims;
            if (claims.isEmpty) {
              return _buildEmptyState();
            }

            // We have data, display the list
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () => UserTuntutanPage(claimId: claim.claimId!),
                      )?.then((_) {
                        _refreshData();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: lightAccentColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tuntutan #${claim.claimId}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              _buildStatusChip(claim.claimOverallStatus),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tarikh Dibuat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          formatDate(claim.claimCreatedAt),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jenis Tuntutan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.category,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          claim.claimType ?? 'Tidak dinyatakan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => UserTuntutanPage(
                                      claimId: claim.claimId!,
                                    ),
                                  )?.then((_) {
                                    _refreshData();
                                  });
                                },
                                icon: Icon(Icons.visibility, size: 16),
                                label: Text('Lihat Details'),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Helper widget to display status chips with appropriate colors
  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'lulus':
        chipColor = Colors.green[600]!;
        statusIcon = Icons.check_circle;
        break;
      case 'gagal':
        chipColor = Colors.red[600]!;
        statusIcon = Icons.cancel;
        break;
      case 'dibatalkan':
        chipColor = Colors.grey[600]!;
        statusIcon = Icons.block;
        textColor = Colors.white70; // Lighter text for grey
        break;
      case 'dalam proses':
      default:
        chipColor = Colors.orange[600]!;
        statusIcon = Icons.hourglass_bottom;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        border: Border.all(color: chipColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: chipColor),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state widget when no claims exist
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_claims.png', // Add this image to your assets
            height: 150,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
          ),
          SizedBox(height: 24),
          Text(
            'Tiada Tuntutan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Anda belum membuat sebarang tuntutan khairat kematian. '
            'Buat tuntutan baru sekarang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => CreateTuntutanPage())?.then((_) {
                setState(() {
                  _userClaims = []; // Clear cache
                  _fetchUserTuntutan(); // Refetch
                });
              });
            },
            icon: Icon(Icons.add),
            label: Text('Buat Tuntutan Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(200, 50),
              elevation: 3,
              shadowColor: primaryColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
