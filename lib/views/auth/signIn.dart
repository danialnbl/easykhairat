import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:easykhairat/views/auth/signUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _passwordVisibility = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      Get.snackbar(
        'Login Failed',
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

          // Content with adaptive layout
          SafeArea(
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
                            // Logo with improved responsiveness
                            Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/easyKhairatLogo.png',
                                width: isWeb ? 120 : (isLandscape ? 80 : 100),
                                height: isWeb ? 120 : (isLandscape ? 80 : 100),
                              ),
                            ),

                            // Additional responsive spacing
                            SizedBox(height: isWeb ? 24 : 16),

                            Text(
                              'Selamat Datang!',
                              style: GoogleFonts.poppins(
                                fontSize: isWeb ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email field
                            _buildTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email Address',
                              hint: 'Enter your email here...',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16.0),

                            // Password field
                            _buildTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: 'Password',
                              hint: 'Enter your password here...',
                              isPassword: true,
                              icon: Icons.lock_outline,
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign in button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 2,
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          'Sign In',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Don't have an account text
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontSize: isWeb ? 14 : 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.to(SignUpWidget()),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: isWeb ? 14 : 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Guest mode button
                            // SizedBox(
                            //   width: isWeb ? 200 : double.infinity,
                            //   child: OutlinedButton(
                            //     onPressed: () => Get.to(() => HomePageWidget()),
                            //     style: OutlinedButton.styleFrom(
                            //       side: BorderSide(color: Colors.grey[400]!),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(25.0),
                            //       ),
                            //       padding: const EdgeInsets.symmetric(
                            //         vertical: 12,
                            //       ),
                            //     ),
                            //     child: Text(
                            //       'Continue as Guest',
                            //       style: GoogleFonts.poppins(
                            //         color: Colors.grey[600],
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
    );
  }

  // Update the _buildTextField method for better cross-platform compatibility:

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    IconData? icon,
    bool isPassword = false,
  }) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !_passwordVisibility,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: isWeb ? 16 : 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[400],
          fontSize: isWeb ? 15 : 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isWeb ? 15 : 12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isWeb ? 15 : 12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isWeb ? 15 : 12),
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
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        suffixIcon:
            isPassword
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisibility = !_passwordVisibility;
                    });
                  },
                  icon: Icon(
                    _passwordVisibility
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                )
                : null,
      ),
      style: GoogleFonts.poppins(fontSize: isWeb ? 16 : 14),
    );
  }
}
