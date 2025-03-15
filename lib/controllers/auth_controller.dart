import 'package:easykhairat/views/admin/admin_main.dart';
import 'package:easykhairat/views/user/home.dart';
import 'package:easykhairat/views/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/userModel.dart' as usermodel;
import 'package:get/get.dart';

final supabase = Supabase.instance.client;

class AuthService {
  // Sign Up Function
  static Future<void> signUp(usermodel.User user, BuildContext context) async {
    try {
      final response = await supabase.auth.signUp(
        email: user.userEmail,
        password: user.userPassword,
        data: {
          'user_name': user.userName,
          'user_identification': user.userIdentification,
          'user_phone_no': user.userPhoneNo,
          'user_address': user.userAddress,
          'user_type': 'user',
          'user_password': user.userPassword,
        },
      );

      if (response.user == null) {
        throw Exception('User creation failed');
      } else {
        print('User created successfully');
        Get.to(() => SignInPage());
      }
    } catch (error) {
      print('Signup error: $error');
      if (error.toString().contains('User already registered')) {
        print('User already exists');
        Get.snackbar(
          'Signup Error',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          snackStyle: SnackStyle.FLOATING,
        );
      }
    }
  }

  // Sign In Function
  static Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Email is confirmed, and login was successful

        // Fetch user type from 'users' table
        final userData =
            await supabase
                .from('users')
                .select('user_type')
                .eq('user_email', email)
                .single();

        String userType = userData['user_type'];

        // Redirect based on user type
        _redirectUser(userType);
      }
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        print('Error: Email is not confirmed.');
        Get.snackbar(
          'Sign-in Error',
          'Please confirm your email before signing in.',
          snackPosition: SnackPosition.BOTTOM,
          snackStyle: SnackStyle.FLOATING,
        );
      } else if (e.message.contains('Invalid login credentials')) {
        print('Error: Invalid email or password.');
        Get.snackbar(
          'Sign-in Error',
          'Invalid email or password.',
          snackPosition: SnackPosition.BOTTOM,
          snackStyle: SnackStyle.FLOATING,
        );
      } else {
        print('Auth error: ${e.message}');
        Get.snackbar(
          'Sign-in Error',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          snackStyle: SnackStyle.FLOATING,
        );
      }
    } catch (e) {
      print('Unexpected error: $e');
      Get.snackbar(
        'Sign-in Error',
        'Something went wrong. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
      );
    }
  }

  // Sign Out Function
  static Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      print('User signed out');

      // Redirect to login screen
      Get.to(() => SignInPage());
    } catch (error) {
      print('Sign-out error: $error');
    }
  }

  static Future<void> resendVerificationEmail(String email) async {
    try {
      await supabase.auth.resend(
        type:
            OtpType
                .signup, // 'signup' for new users, 'email_change' for email updates
        email: email,
      );
      Get.snackbar('Email Sent', 'A new verification email has been sent.');
    } catch (error) {
      print('Resend email error: $error');
      Get.snackbar('Error', 'Failed to resend verification email.');
    }
  }

  // Redirect User Based on User Type
  static void _redirectUser(String userType) {
    if (userType == 'admin') {
      Get.to(() => AdminMain());
    } else {
      Get.to(() => HomePageWidget());
    }
  }
}
