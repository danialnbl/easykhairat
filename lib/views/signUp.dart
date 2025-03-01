import 'package:easykhairat/models/userModel.dart';
import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/views/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    // Check for empty fields
    if (_nameController.text.trim().isEmpty ||
        _icController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Check for password match
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Create user object
    final newUser = User(
      userName: _nameController.text.trim(),
      userIdentification: _icController.text.trim(),
      userPhoneNo: _phoneController.text.trim(),
      userAddress: _addressController.text.trim(),
      userEmail: _emailController.text.trim(),
      userType: 'user', // Default user type (can change if you want admin)
      userPassword: _passwordController.text.trim(),
      userCreatedAt: DateTime.now(),
    );

    // Call sign up
    try {
      await AuthService.signUp(newUser, context);
      // Navigation happens inside AuthService based on userType
    } catch (e) {
      Get.snackbar(
        'Signup Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/easyKhairatLogo.png',
                    width: 150,
                    height: 150,
                  ),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  buildTextField(
                    'Full Name',
                    _nameController,
                    TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  buildTextField(
                    'IC Number',
                    _icController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 16),

                  buildTextField(
                    'Phone Number',
                    _phoneController,
                    TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  buildTextField(
                    'Home Address',
                    _addressController,
                    TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 16),

                  buildTextField(
                    'Email Address',
                    _emailController,
                    TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  buildPasswordField(
                    'Password',
                    _passwordController,
                    _passwordVisibility,
                    () {
                      setState(
                        () => _passwordVisibility = !_passwordVisibility,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  buildPasswordField(
                    'Confirm Password',
                    _confirmPasswordController,
                    _confirmPasswordVisibility,
                    () {
                      setState(
                        () =>
                            _confirmPasswordVisibility =
                                !_confirmPasswordVisibility,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Or sign up with',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                          ), // Border color and width
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ), // Optional: Rounded corners
                        ),
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // Google sign-in logic
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                          ), // Border color and width
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ), // Optional: Rounded corners
                        ),
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.apple,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Apple sign-in logic
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),

                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Already have an account? Sign In',
                      style: GoogleFonts.poppins(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget buildPasswordField(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
