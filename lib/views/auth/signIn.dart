import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:easykhairat/views/auth/signUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      await AuthService.signIn(
        _emailController.text,
        _passwordController.text,
        context,
      );
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !_passwordVisibility,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40.0)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon:
            isPassword
                ? InkWell(
                  onTap: () {
                    setState(() {
                      _passwordVisibility = !_passwordVisibility;
                    });
                  },
                  child: Icon(
                    _passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth > 600 ? 500 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/easyKhairatLogo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.fitWidth,
                        ),
                        Text(
                          'Selamat Datang!',
                          style: GoogleFonts.poppins(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email Address',
                          hint: 'Enter your email here...',
                        ),
                        const SizedBox(height: 16.0),
                        _buildTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          label: 'Password',
                          hint: 'Enter your password here...',
                          isPassword: true,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(color: Colors.blue),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _handleSignin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              FontAwesomeIcons.google,
                              Colors.red,
                              () {},
                            ),
                            const SizedBox(width: 20.0),
                            _buildSocialButton(
                              FontAwesomeIcons.apple,
                              Colors.black,
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () => Get.to(() => SignUpWidget()),
                          child: Text(
                            "Don't have an account? Create one",
                            style: GoogleFonts.poppins(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        OutlinedButton(
                          onPressed: () => Get.to(() => HomePageWidget()),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Continue as Guest',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildSocialButton(IconData icon, Color color, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: IconButton(icon: FaIcon(icon, color: color), onPressed: onPressed),
  );
}
