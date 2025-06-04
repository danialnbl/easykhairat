import 'dart:async';

import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:easykhairat/views/user/user_tuntutan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTuntutanPage extends StatefulWidget {
  const CreateTuntutanPage({Key? key}) : super(key: key);

  @override
  _CreateTuntutanPageState createState() => _CreateTuntutanPageState();
}

class _CreateTuntutanPageState extends State<CreateTuntutanPage> {
  final TuntutanController tuntutanController = Get.put(TuntutanController());
  final supabase = Supabase.instance.client;

  // Form controllers for creating new claim
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _claimTypeController = TextEditingController();
  bool isLoading = false;
  bool isCreatingNew = false;

  // Store claims in a state variable to avoid repeated fetching
  List<ClaimModel> _userClaims = [];
  bool _hasLoadedInitially = false;

  @override
  void initState() {
    super.initState();
    _claimTypeController.text = 'Ahli Sendiri'; // Default value
    _fetchUserTuntutan(); // Load user's claims on init
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Fetch user's tuntutan list with improved error handling and caching
  Future<List<ClaimModel>> _fetchUserTuntutan() async {
    // If we already have data and this isn't a forced refresh, return cached data
    if (_userClaims.isNotEmpty && _hasLoadedInitially) {
      return _userClaims;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          isLoading = false;
        });
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
      print('Error fetching user tuntutan: $e');
      setState(() {
        isLoading = false;
      });

      // Show error to user
      Get.snackbar(
        'Error',
        'Failed to load claims: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        duration: Duration(seconds: 3),
      );

      // Return cached data if available, otherwise empty list
      return _userClaims.isNotEmpty ? _userClaims : [];
    }
  }

  // Create a new claim
  Future<void> _createNewClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please log in to make a claim');
        return;
      }

      // Use the controller to create the claim
      final createdClaim = await tuntutanController.createTuntutan(
        userId: userId,
        claimType: _claimTypeController.text,
      );

      if (createdClaim != null) {
        // Add to our cached list
        setState(() {
          _userClaims = [createdClaim, ..._userClaims];
        });

        Get.snackbar(
          'Success',
          'Claim submitted successfully',
          backgroundColor: Colors.green.shade100,
        );

        // Switch back to list view and refresh
        setState(() {
          isCreatingNew = false;
          isLoading = false;
        });

        // Navigate to the details page of the newly created claim
        Get.to(() => UserTuntutanPage(claimId: createdClaim.claimId!))?.then((
          _,
        ) {
          // Refresh list when returning from details
          setState(() {
            _userClaims = []; // Clear cache to ensure fresh data
            _fetchUserTuntutan();
          });
        });
      }
    } catch (e) {
      print('Error creating claim: $e');
      Get.snackbar(
        'Error',
        'Failed to submit claim: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      appBar: AppBar(
        title: Text(isCreatingNew ? 'Buat Tuntutan Baru' : 'Senarai Tuntutan'),
        backgroundColor: MoonColors.light.bulma,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isCreatingNew
              ? _buildCreateNewForm()
              : RefreshIndicator(
                onRefresh: () async {
                  await _fetchUserTuntutan();
                  setState(() {});
                },
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
      floatingActionButton:
          isCreatingNew
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    isCreatingNew = true;
                  });
                },
                label: Text('Buat Tuntutan'),
                icon: Icon(Icons.add),
                backgroundColor: MoonColors.light.bulma,
              ),
    );
  }

  // Build the list of user's tuntutan
  Widget _buildTuntutanList() {
    // Use a StatefulBuilder to avoid flickering when refreshing
    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<List<ClaimModel>>(
          future: _fetchUserTuntutan(), // Use our updated fetch method
          builder: (context, snapshot) {
            // Show loading indicator only on initial load
            if (!_hasLoadedInitially &&
                (snapshot.connectionState == ConnectionState.waiting ||
                    isLoading)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading tuntutan...'),
                    ],
                  ),
                ),
              );
            }

            // If error, show error with cached data if available
            if (snapshot.hasError && _userClaims.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: Failed to load claims'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasLoadedInitially = false;
                          _fetchUserTuntutan();
                        });
                      },
                      child: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoonColors.light.bulma,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            List<ClaimModel> claims = snapshot.data ?? _userClaims;
            if (claims.isEmpty) {
              return _buildEmptyState();
            }

            // We have data, display the list
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                            icon: Icon(
                              Icons.refresh,
                              color: MoonColors.light.bulma,
                            ),
                            onPressed: () {
                              setState(() {
                                _userClaims = []; // Clear cache
                                _fetchUserTuntutan(); // Refetch
                              });
                            },
                          ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: claims.length,
                  itemBuilder: (context, index) {
                    final claim = claims[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          // Navigate to details page with this claim
                          Get.to(
                            () => UserTuntutanPage(claimId: claim.claimId!),
                          )?.then((_) {
                            // Refresh list when returning from details page
                            setState(() {
                              _userClaims = []; // Clear cache
                              _fetchUserTuntutan(); // Refetch
                            });
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tuntutan #${claim.claimId}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  _buildStatusChip(claim.claimOverallStatus),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    formatDate(claim.claimCreatedAt),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(
                                    Icons.category,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    claim.claimType ?? 'Tidak dinyatakan',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
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
                                        // Refresh list when returning from details page
                                        setState(() {
                                          _userClaims = []; // Clear cache
                                          _fetchUserTuntutan(); // Refetch
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.visibility, size: 16),
                                    label: Text('Lihat Details'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: MoonColors.light.bulma,
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build the form for creating a new claim
  Widget _buildCreateNewForm() {
    return SingleChildScrollView(
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
                          'Buat Tuntutan Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sila lengkapkan maklumat di bawah untuk memulakan proses tuntutan khairat kematian.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // New claim form
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maklumat Tuntutan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Jenis Tuntutan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: 'Ahli Sendiri',
                        items: [
                          DropdownMenuItem(
                            value: 'Ahli Sendiri',
                            child: Text('Ahli Sendiri'),
                          ),
                          DropdownMenuItem(
                            value: 'Tanggungan',
                            child: Text('Tanggungan'),
                          ),
                        ],
                        onChanged: (value) {
                          _claimTypeController.text = value.toString();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sila pilih jenis tuntutan';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  isCreatingNew = false;
                                });
                              },
                              child: Text('Kembali'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child:
                                isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : ElevatedButton.icon(
                                      onPressed: _createNewClaim,
                                      icon: Icon(Icons.send),
                                      label: Text('Hantar Tuntutan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: MoonColors.light.bulma,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nota: Setelah hantar tuntutan, anda boleh tambah butiran tuntutan seperti sijil kematian atau bukti lain.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  // Empty state widget when no claims exist
  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Tiada Tuntutan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Anda belum membuat sebarang tuntutan khairat kematian.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isCreatingNew = true;
                  });
                },
                icon: Icon(Icons.add),
                label: Text('Buat Tuntutan Baru'),
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

  @override
  void dispose() {
    _claimTypeController.dispose();
    super.dispose();
  }
}
