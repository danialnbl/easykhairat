import 'dart:async';
import 'dart:io';

import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:easykhairat/views/user/user_tuntutan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

final primaryColor = Color(0xFF2BAAAD);
final secondaryColor = Color(0xFF35C2C5);
final accentColor = Color(0xFF1D7F82);
final lightAccentColor = Color(0xFFE0F7F8);
final backgroundColor = Color(0xFFF5FCFC);

class CreateTuntutanPage extends StatefulWidget {
  const CreateTuntutanPage({Key? key}) : super(key: key);

  @override
  _CreateTuntutanPageState createState() => _CreateTuntutanPageState();
}

class _CreateTuntutanPageState extends State<CreateTuntutanPage> {
  final TuntutanController tuntutanController = Get.put(TuntutanController());
  final supabase = Supabase.instance.client;

  // Step tracking
  int _currentStep = 0;
  ClaimModel? _createdClaim;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _certificateFormKey = GlobalKey<FormState>();
  final TextEditingController _claimTypeController = TextEditingController();

  bool isLoading = false;

  // Image upload variables
  File? _certificateImage;
  String? _certificateUrl;
  bool _isUploading = false;

  // Modify _CreateTuntutanPageState to store form values temporarily without creating a claim
  // Add these variables to store form data before creating the claim
  String _selectedClaimType = 'Ahli Sendiri';
  String? _uploadedCertificateUrl;

  @override
  void initState() {
    super.initState();
    _claimTypeController.text = 'Ahli Sendiri'; // Default value
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Step 1: Collect basic info (no database operation)
  void _validateBasicInfoAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _selectedClaimType = _claimTypeController.text;
      _currentStep = 1; // Move to certificate upload step
    });
  }

  // Step 2: Upload death certificate
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );

    if (pickedFile != null) {
      setState(() {
        _certificateImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadCertificateAndContinue() async {
    if (!_certificateFormKey.currentState!.validate()) return;

    if (_certificateImage == null) {
      Get.snackbar('Perhatian', 'Sila muatnaik sijil kematian');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image and get URL
      final String fileName =
          'temp_${DateTime.now().millisecondsSinceEpoch}${path.extension(_certificateImage!.path)}';
      await supabase.storage
          .from('certificates')
          .upload(
            'certificates/$fileName',
            _certificateImage!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String imageUrl = supabase.storage
          .from('certificates')
          .getPublicUrl('certificates/$fileName');

      setState(() {
        _uploadedCertificateUrl = imageUrl;
        _currentStep = 2; // Move to create claim step
      });

      // Now create the claim with the uploaded certificate
      await _createClaimWithCertificate();
    } catch (e) {
      print('Error uploading certificate: $e');
      Get.snackbar('Error', 'Gagal memuat naik sijil: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Step 3: Create the claim with all data collected so far
  Future<void> _createClaimWithCertificate() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please log in to make a claim');
        return;
      }

      // Create claim with certificate URL already included
      final createdClaim = await tuntutanController.createTuntutan(
        userId: userId,
        claimType: _selectedClaimType,
        certificateUrl: _uploadedCertificateUrl,
      );

      if (createdClaim != null) {
        _createdClaim = createdClaim;
        setState(() {
          _currentStep = 2; // Move to claim line items
        });

        Get.snackbar(
          'Berjaya',
          'Tuntutan telah dicipta. Sila tambah butiran perbelanjaan.',
          backgroundColor: Colors.green.shade100,
        );
      }
    } catch (e) {
      print('Error creating claim: $e');
      Get.snackbar('Error', 'Failed to create claim: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Navigate to the finished claim
  void _navigateToFinishedClaim() {
    if (_createdClaim != null) {
      Get.to(() => UserTuntutanPage(claimId: _createdClaim!.claimId!))?.then((
        _,
      ) {
        // Go back to list page after viewing details
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Buat Tuntutan Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // If we've already created a claim and we're trying to go back
            if (_createdClaim != null && _currentStep > 0) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Batalkan Tuntutan?'),
                    content: Text(
                      'Anda telah memulakan proses permohonan tuntutan. '
                      'Adakah anda pasti mahu keluar? Tuntutan yang telah dibuat akan disimpan.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: Text('TERUSKAN TUNTUTAN'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Get.back(); // Go back to list
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('KELUAR'),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              );
            } else {
              Get.back(); // Just go back without warning
            }
          },
        ),
      ),
      body: _buildStepperView(),
    );
  }

  Widget _buildStepperView() {
    return Column(
      children: [
        // Linear progress indicator to show overall progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progres',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(_currentStep + 1)}/4',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                color: primaryColor,
                backgroundColor: lightAccentColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // Existing Stepper code
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryColor,
                secondary: secondaryColor,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
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
                          onPressed:
                              isLoading || _isUploading
                                  ? null
                                  : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MoonColors.light.bulma,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              isLoading || _isUploading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(_getButtonTextForStep(_currentStep)),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onStepContinue: () {
                if (_currentStep == 0) {
                  _validateBasicInfoAndContinue();
                } else if (_currentStep == 1) {
                  _uploadCertificateAndContinue();
                } else if (_currentStep == 2) {
                  _navigateToFinishedClaim();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep--;
                  });
                }
              },
              type: StepperType.vertical,
              steps: [
                Step(
                  title: Text('Maklumat Asas'),
                  content: _buildBasicClaimForm(),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Muatnaik Sijil Kematian'),
                  content: _buildCertificateUploadForm(),
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Semak & Hantar'),
                  content: _buildClaimReview(),
                  isActive: _currentStep >= 2,
                  state:
                      _currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonTextForStep(int step) {
    switch (step) {
      case 0:
        return 'Teruskan';
      case 1:
        return 'Muat Naik & Teruskan';
      case 2:
        return 'Teruskan ke Semakan';
      case 3:
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
          if (isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memproses...',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          Text(
            'Nota: Setelah mencipta tuntutan asas, anda akan diminta untuk memuat naik sijil kematian.',
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

  // NEW: Certificate upload form widget
  Widget _buildCertificateUploadForm() {
    return Form(
      key: _certificateFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sijil Kematian',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),

          // Image selection area
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: lightAccentColor.withOpacity(0.3),
              ),
              child:
                  _certificateImage != null
                      ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _certificateImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                            onPressed: () {
                              setState(() {
                                _certificateImage = null;
                              });
                            },
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: primaryColor,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tekan untuk memuat naik sijil kematian',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Format diterima: JPG, PNG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
            ),
          ),

          SizedBox(height: 16),

          if (_isUploading)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Memuat naik sijil kematian...'),
                ],
              ),
            ),

          SizedBox(height: 16),

          Text(
            'Nota: Sijil kematian yang dimuat naik mestilah jelas dan dokumen rasmi.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimReview() {
    return SingleChildScrollView(
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
                  _buildInfoRow(
                    'ID Tuntutan',
                    '#${_createdClaim?.claimId ?? ''}',
                  ),
                  _buildInfoRow(
                    'Jenis Tuntutan',
                    _createdClaim?.claimType ?? _selectedClaimType,
                  ),
                  _buildInfoRow(
                    'Status',
                    _createdClaim?.claimOverallStatus ?? 'Baru',
                  ),
                  _buildInfoRow(
                    'Tarikh Dibuat',
                    formatDate(_createdClaim?.claimCreatedAt ?? DateTime.now()),
                  ),

                  // Add certificate information
                  if (_createdClaim?.claimReason != null &&
                      _createdClaim!.claimReason!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Maklumat Si Mati',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Divider(),
                    _buildInfoRow('Nama Si Mati', _createdClaim!.claimReason!),
                  ],

                  if (_certificateImage != null || _certificateUrl != null)
                    _buildInfoRow('Sijil Kematian', 'Dimuat naik'),

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

  @override
  void dispose() {
    _claimTypeController.dispose();
    super.dispose();
  }
}
