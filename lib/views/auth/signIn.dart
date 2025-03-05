import 'package:easykhairat/controllers/auth_controller.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:easykhairat/views/auth/signUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
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
    // Check for empty fields
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/easyKhairatLogo.png',
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      'Selamat Datang!',
                      style: GoogleFonts.poppins(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: 4.0),
                    // Text(
                    //   'Gunakan borang di bawah untuk mengakses akaun anda.',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 14.0,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email here...',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_passwordVisibility,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password here...',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: InkWell(
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
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Forgot Password logic
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Sign in logic
                            _handleSignin();
                          },
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
                    SizedBox(height: 16.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Resend verification email logic
                          if (_emailController.text != null) {
                            AuthService.resendVerificationEmail(
                              _emailController.text,
                            );
                            Get.snackbar(
                              'Email Sent',
                              'A new verification email has been sent.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please enter your email address',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          'Resend verification email',
                          style: GoogleFonts.poppins(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'Or sign in with',
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
                        SizedBox(width: 20.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
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
                    SizedBox(height: 20.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => SignUpWidget());
                        },
                        child: Text(
                          'Don\'t have an account? Create one',
                          style: GoogleFonts.poppins(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          // Guest sign-in logic
                          Get.to(() => HomePageWidget());
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
