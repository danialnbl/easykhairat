import 'package:easykhairat/controllers/session_controller.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/userModel.dart' as usermodel;
import 'package:get/get.dart';

final supabase = Supabase.instance.client;
final UserController userController = Get.put(UserController());

class AuthService {
  static Future<void> signUp(usermodel.User user) async {
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
        },
      );

      if (response.user == null) {
        throw Exception('User creation failed');
      }

      Get.snackbar("Berjaya", "Maklumat ahli baru telah disimpan.");
    } catch (error) {
      Get.snackbar(
        "Ralat",
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  static Future<void> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Let SessionController handle the redirection based on session state
        SessionController().checkSession();
      }
    } catch (e) {
      Get.snackbar('Sign-in Error', 'Something went wrong.');
    }
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
    SessionController()
        .checkSession(); // This will handle redirection to sign-in page
  }
}
