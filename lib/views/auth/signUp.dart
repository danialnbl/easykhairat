import 'package:easykhairat/models/userModel.dart';
import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui'; // Add this import for BackdropFilter

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user object
      final newUser = User(
        userName: _nameController.text.trim(),
        userIdentification: _icController.text.trim(),
        userPhoneNo: _phoneController.text.trim(),
        userAddress: _addressController.text.trim(),
        userEmail: _emailController.text.trim(),
        userType: 'user',
        userPassword: _passwordController.text.trim(),
        userCreatedAt: DateTime.now(),
        userUpdatedAt: DateTime.now(),
        userId: '',
      );

      await AuthService.signUp(newUser);

      Get.to(() => SignInPage());

      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        'Signup Failed',
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
          // Background Image with blur effect like SignIn page
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
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.85),
                      child: Padding(
                        padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo with responsive size
                            Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/easyKhairatLogo.png',
                                width: isWeb ? 120 : 100,
                                height: isWeb ? 120 : 100,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: isWeb ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: isWeb ? 24 : 16),

                            // Form fields - adapt layout based on screen size
                            if (isWeb)
                              _buildWebFormLayout()
                            else
                              _buildMobileFormLayout(),

                            SizedBox(height: isWeb ? 24 : 16),

                            // Submit button
                            SizedBox(
                              width:
                                  isWeb ? screenWidth * 0.25 : double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
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
                                          'Sign Up',
                                          style: GoogleFonts.poppins(
                                            fontSize: isWeb ? 16 : 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Wrap this in a FittedBox to avoid overflow
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontSize: isWeb ? 14 : 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.to(SignInPage()),
                                    child: Text(
                                      'Sign In',
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

  // Modified web form layout with better constraints
  Widget _buildWebFormLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValidatedField(
                    'Full Name',
                    _nameController,
                    TextInputType.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildValidatedField(
                    'IC Number',
                    _icController,
                    TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValidatedField(
                    'Phone Number',
                    _phoneController,
                    TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildValidatedField(
                    'Email Address',
                    _emailController,
                    TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              'Home Address',
              _addressController,
              TextInputType.streetAddress,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPasswordField(
                    'Password',
                    _passwordController,
                    _passwordVisibility,
                    () => setState(
                      () => _passwordVisibility = !_passwordVisibility,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPasswordField(
                    'Confirm Password',
                    _confirmPasswordController,
                    _confirmPasswordVisibility,
                    () => setState(
                      () =>
                          _confirmPasswordVisibility =
                              !_confirmPasswordVisibility,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileFormLayout() {
    return Column(
      children: [
        _buildValidatedField('Full Name', _nameController, TextInputType.name),
        const SizedBox(height: 16),
        _buildValidatedField('IC Number', _icController, TextInputType.text),
        const SizedBox(height: 16),
        _buildValidatedField(
          'Phone Number',
          _phoneController,
          TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildValidatedField(
          'Home Address',
          _addressController,
          TextInputType.streetAddress,
        ),
        const SizedBox(height: 16),
        _buildValidatedField(
          'Email Address',
          _emailController,
          TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          'Password',
          _passwordController,
          _passwordVisibility,
          () => setState(() => _passwordVisibility = !_passwordVisibility),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          'Confirm Password',
          _confirmPasswordController,
          _confirmPasswordVisibility,
          () => setState(
            () => _confirmPasswordVisibility = !_confirmPasswordVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (label == 'Email Address' && !GetUtils.isEmail(value)) {
          return 'Please enter a valid email address';
        }
        if (label == 'Phone Number' && !GetUtils.isPhoneNumber(value)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggle,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: onToggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (value.length < 6) {
          return 'Password should be at least 6 characters';
        }
        if (label == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
