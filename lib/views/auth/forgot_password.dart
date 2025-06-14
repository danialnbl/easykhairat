import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Ralat',
        'Sila masukkan alamat e-mel anda',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Ralat',
        'Sila masukkan alamat e-mel yang sah',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(email);
      // We don't navigate away since the snackbar tells them to check their email
    } catch (e) {
      Get.snackbar(
        'Ralat',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to adapt layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 800;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with improved cross-platform compatibility
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/mosque_interior.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // Darkened for better contrast
                  BlendMode.darken,
                ),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isWeb ? 5 : 3,
                sigmaY: isWeb ? 5 : 3,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Overlay gradient - reduced opacity for better look
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.4),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? screenWidth * 0.1 : 16.0,
                          vertical: 20.0,
                        ),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: EdgeInsets.all(isWeb ? 32.0 : 16.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isWeb ? 500 : double.infinity,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/easyKhairatLogo.png',
                                    width:
                                        isWeb ? 100 : (isLandscape ? 70 : 80),
                                    height:
                                        isWeb ? 100 : (isLandscape ? 70 : 80),
                                  ),

                                  SizedBox(height: isWeb ? 24 : 16),

                                  Text(
                                    'Tetapan Semula Kata Laluan',
                                    style: GoogleFonts.poppins(
                                      fontSize: isWeb ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: 16),

                                  Text(
                                    'Masukkan alamat e-mel yang berdaftar. Kami akan menghantar arahan untuk menetapkan semula kata laluan anda.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: 24),

                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Alamat E-mel',
                                      hintText: 'Masukkan e-mel anda disini...',
                                      labelStyle: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: isWeb ? 16 : 14,
                                      ),
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: isWeb ? 15 : 13,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          isWeb ? 15 : 12,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          isWeb ? 15 : 12,
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          isWeb ? 15 : 12,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: isWeb ? 2 : 1.5,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isWeb ? 20 : 16,
                                        vertical: isWeb ? 20 : 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: isWeb ? 16 : 14,
                                    ),
                                  ),

                                  SizedBox(height: 24),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : _handleResetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Text(
                                                'Hantar',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text(
                                      'Kembali ke Log Masuk',
                                      style: GoogleFonts.poppins(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
