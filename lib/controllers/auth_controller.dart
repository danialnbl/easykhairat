import 'package:easykhairat/views/signIn.dart';
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
        _redirectUser();
      }
    } catch (error) {
      print('Signup error: $error');
      if (error.toString().contains('User already registered')) {
        print('User already exists');
        Get.snackbar(
          'Signup Error',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
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
        // Fetch user type from 'users' table
        final userData =
            await supabase
                .from('users')
                .select('user_type')
                .eq('user_email', email)
                .single();

        String userType = userData['user_type'];
        print('User Type: $userType');

        // Redirect based on user type
        _redirectUser();
      }
    } catch (error) {
      print('Sign-in error: $error');
    }
  }

  // Sign Out Function
  static Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      print('User signed out');

      // Redirect to login screen
      Get.to(() => SignInWidget());
    } catch (error) {
      print('Sign-out error: $error');
    }
  }

  // Redirect User Based on User Type
  static void _redirectUser() {
    Get.to(() => SignInWidget());
  }
}
