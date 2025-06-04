import 'dart:async';

import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/claimLineModel.dart';
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
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );
  final supabase = Supabase.instance.client;

  // Step tracking
  int _currentStep = 0;
  ClaimModel? _createdClaim;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _claimLineFormKey = GlobalKey<FormState>();
  final TextEditingController _claimTypeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool isLoading = false;
  bool isCreatingNew = false;

  // Added temporary claim lines
  List<ClaimLineModel> _tempClaimLines = [];

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

  // Step 1: Create a new base claim
  Future<void> _createBaseClaimAndContinue() async {
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
        // Store created claim reference for later use
        _createdClaim = createdClaim;

        // Add to our cached list
        setState(() {
          _userClaims = [createdClaim, ..._userClaims];
          _currentStep = 1; // Move to next step
          isLoading = false;
        });

        Get.snackbar(
          'Berjaya',
          'Tuntutan asas telah dicipta. Sila tambahkan butiran perbelanjaan.',
          backgroundColor: Colors.green.shade100,
        );
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

  // Step 2: Add claim line items
  Future<void> _addClaimLine() async {
    if (!_claimLineFormKey.currentState!.validate()) return;

    // Validate amount input
    double? amount;
    try {
      amount = double.parse(_amountController.text.trim());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Jumlah mesti dalam format angka yang betul.',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah mesti lebih daripada RM0.',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create a new claim line
      final newClaimLine = ClaimLineModel(
        claimLineReason: _reasonController.text.trim(),
        claimLineTotalPrice: amount,
        claimLineCreatedAt: DateTime.now(),
        claimLineUpdatedAt: DateTime.now(),
        claimId: _createdClaim!.claimId,
      );

      // Add to Supabase
      await claimLineController.addClaimLine(newClaimLine);

      // Add to temp list for UI display
      setState(() {
        _tempClaimLines.add(newClaimLine);
      });

      // Clear the form
      _reasonController.clear();
      _amountController.clear();

      Get.snackbar(
        'Berjaya',
        'Butiran perbelanjaan telah ditambah',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      print('Error adding claim line: $e');
      Get.snackbar(
        'Error',
        'Gagal menambah perbelanjaan: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 3: Complete the claiming process
  void _completeClaimProcess() {
    if (_tempClaimLines.isEmpty) {
      Get.snackbar(
        'Amaran',
        'Anda belum menambah sebarang butiran perbelanjaan. Adakah anda pasti mahu teruskan?',
        backgroundColor: Colors.amber.shade100,
        duration: Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            _navigateToFinishedClaim();
          },
          child: Text('Ya, Teruskan', style: TextStyle(color: Colors.black87)),
        ),
      );
    } else {
      _navigateToFinishedClaim();
    }
  }

  // Navigate to the finished claim
  void _navigateToFinishedClaim() {
    if (_createdClaim != null) {
      Get.to(() => UserTuntutanPage(claimId: _createdClaim!.claimId!))?.then((
        _,
      ) {
        // Refresh list when returning from details
        setState(() {
          isCreatingNew = false;
          _currentStep = 0;
          _userClaims = []; // Clear cache to ensure fresh data
          _fetchUserTuntutan();
          _createdClaim = null;
          _tempClaimLines = [];
        });
      });
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
              ? _buildStepperView()
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

  Widget _buildStepperView() {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: MoonColors.light.bulma),
      ),
      child: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          // Custom controls based on the current step
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: Text('Kembali'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MoonColors.light.bulma,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_getButtonTextForStep(_currentStep)),
                  ),
                ),
              ],
            ),
          );
        },
        onStepContinue: () {
          if (_currentStep == 0) {
            _createBaseClaimAndContinue();
          } else if (_currentStep == 1) {
            _currentStep = 2;
            setState(() {});
          } else if (_currentStep == 2) {
            _completeClaimProcess();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            // If at first step, cancel the whole process
            setState(() {
              isCreatingNew = false;
              _createdClaim = null;
              _tempClaimLines = [];
            });
          }
        },
        type: StepperType.vertical,
        steps: [
          Step(
            title: Text('Maklumat Asas'),
            content: _buildBasicClaimForm(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Butiran Perbelanjaan'),
            content: _buildClaimLineForm(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text('Semak & Hantar'),
            content: _buildClaimReview(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  String _getButtonTextForStep(int step) {
    switch (step) {
      case 0:
        return 'Teruskan';
      case 1:
        return 'Semak & Hantar';
      case 2:
        return 'Selesai';
      default:
        return 'Teruskan';
    }
  }

  Widget _buildBasicClaimForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih jenis tuntutan yang anda ingin buat:',
            style: TextStyle(fontWeight: FontWeight.bold),
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
              DropdownMenuItem(value: 'Tanggungan', child: Text('Tanggungan')),
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
          SizedBox(height: 16),
          if (isLoading) Center(child: CircularProgressIndicator()),
          SizedBox(height: 16),
          Text(
            'Nota: Setelah mencipta tuntutan asas, anda akan diminta untuk menambahkan butiran perbelanjaan.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimLineForm() {
    if (_createdClaim == null) {
      return Center(
        child: Text('Sila lengkapkan langkah pertama terlebih dahulu'),
      );
    }

    return SingleChildScrollView(
      // Wrap in SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card to show claim type
          Card(
            color: MoonColors.light.beerus,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: MoonColors.light.hit),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tuntutan ID: #${_createdClaim!.claimId}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Jenis: ${_createdClaim!.claimType}',
                          overflow:
                              TextOverflow
                                  .ellipsis, // Add ellipsis for long text
                        ),
                        Text('Status: ${_createdClaim!.claimOverallStatus}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tambah Butiran Perbelanjaan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Form(
            key: _claimLineFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Penerangan Perbelanjaan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Cth: Kos pengebumian',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sila masukkan penerangan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Jumlah (RM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: 'Cth: 1000.00',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sila masukkan jumlah';
                    }

                    try {
                      double amount = double.parse(value);
                      if (amount <= 0) {
                        return 'Jumlah mesti lebih daripada RM0';
                      }
                    } catch (e) {
                      return 'Sila masukkan nilai yang sah';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _addClaimLine,
                  icon: Icon(Icons.add),
                  label: Text('Tambah Perbelanjaan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MoonColors.light.hit,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Show list of added claim lines
          if (_tempClaimLines.isNotEmpty) ...[
            Text(
              'Perbelanjaan yang Ditambah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _tempClaimLines.length,
              itemBuilder: (context, index) {
                final claimLine = _tempClaimLines[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      claimLine.claimLineReason,
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for long text
                      maxLines: 2, // Allow up to two lines
                    ),
                    subtitle: Text(
                      'Ditambah pada ${DateFormat('dd/MM/yyyy HH:mm').format(claimLine.claimLineCreatedAt)}',
                      style: TextStyle(fontSize: 12), // Slightly smaller font
                    ),
                    trailing: Text(
                      'RM ${claimLine.claimLineTotalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MoonColors.light.bulma,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            // Show total
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MoonColors.light.beerus,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM ${_tempClaimLines.fold(0.0, (sum, item) => sum + item.claimLineTotalPrice).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: MoonColors.light.bulma,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16),
          if (_tempClaimLines.isEmpty)
            Center(
              child: Text(
                'Belum ada perbelanjaan yang ditambah.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClaimReview() {
    if (_createdClaim == null) {
      return Center(
        child: Text(
          'Sila lengkapkan langkah-langkah sebelumnya terlebih dahulu',
        ),
      );
    }

    final double totalAmount = _tempClaimLines.fold(
      0.0,
      (sum, item) => sum + item.claimLineTotalPrice,
    );

    return SingleChildScrollView(
      // Wrap in SingleChildScrollView to prevent vertical overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Tuntutan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Claim details card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maklumat Tuntutan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Divider(),
                  _buildInfoRow('ID Tuntutan', '#${_createdClaim!.claimId}'),
                  _buildInfoRow(
                    'Jenis Tuntutan',
                    _createdClaim!.claimType ?? 'N/A',
                  ),
                  _buildInfoRow('Status', _createdClaim!.claimOverallStatus),
                  _buildInfoRow(
                    'Tarikh Dibuat',
                    formatDate(_createdClaim!.claimCreatedAt),
                  ),
                  SizedBox(height: 16),

                  // Claim line summary
                  Text(
                    'Butiran Perbelanjaan (${_tempClaimLines.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Divider(),
                  if (_tempClaimLines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Tiada perbelanjaan ditambah.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  if (_tempClaimLines.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _tempClaimLines.length,
                      itemBuilder: (context, index) {
                        final item = _tempClaimLines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start, // Align to top in case of text wrapping
                            children: [
                              // Fixed: Added flexible to allow text wrapping
                              Flexible(
                                flex: 3,
                                child: Text(
                                  item.claimLineReason,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(width: 8), // Add spacing between columns
                              Text(
                                'RM ${item.claimLineTotalPrice.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'RM ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: MoonColors.light.bulma,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Dengan menekan butang "Selesai", anda mengesahkan bahawa semua maklumat yang diberikan adalah benar.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top for multi-line text
        children: [
          Flexible(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          SizedBox(width: 8), // Add spacing between columns
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right, // Right-align the value
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), // Reduced padding
      constraints: BoxConstraints(maxWidth: 100), // Add max width constraint
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center, // Center the text
        overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11, // Slightly smaller font
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
    _reasonController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
