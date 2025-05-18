import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/userModel.dart' as pengguna;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserController extends GetxController {
  var users = <pengguna.User>[].obs;
  var adminUsers = <pengguna.User>[].obs;
  var normalusers = <pengguna.User>[].obs;
  var adminLogged = ''.obs;
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Listen for real-time updates
    listenForRealTimeUpdates();
  }

  // Fetch all users from the 'users' table
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('users').select();

      final fetchedUsers =
          (response as List<dynamic>)
              .map(
                (json) => pengguna.User.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      users.assignAll(fetchedUsers);
    } catch (e) {
      print("Error fetching users: $e");
      Get.snackbar('Error', 'Failed to fetch users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdmin() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('users')
          .select()
          .eq('user_type', 'admin');

      final fetchedAdmins =
          (response as List<dynamic>)
              .map(
                (json) => pengguna.User.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      adminUsers.assignAll(fetchedAdmins);
    } catch (e) {
      print("Error fetching admins: $e");
      Get.snackbar('Error', 'Failed to fetch admins');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNormal() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('users')
          .select()
          .eq('user_type', 'user');

      final fetchedNormal =
          (response as List<dynamic>)
              .map(
                (json) => pengguna.User.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      normalusers.assignAll(fetchedNormal);
    } catch (e) {
      print("Error fetching normal user: $e");
      Get.snackbar('Error', 'Failed to fetch normal user');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch a user by user ID
  Future<pengguna.User?> fetchUserById(String userId) async {
    try {
      isLoading.value = true;
      final response =
          await supabase.from('users').select().eq('user_id', userId).single();

      if (response != null) {
        return pengguna.User.fromJson(response as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user by ID: $e");
      Get.snackbar('Error', 'Failed to fetch user by ID');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch admin by user ID by joining with the admin table
  Future<void> fetchAdminDetailsByIdAndAssign(String userId) async {
    try {
      isLoading.value = true;
      final response =
          await supabase
              .from('admin')
              .select('admin_id, users(*)')
              .eq('user_id', userId)
              .single();

      if (response != null) {
        final adminId = response['admin_id']?.toString();
        if (adminId != null) {
          adminLogged.value = adminId;
        }
      }
    } catch (e) {
      print("Error fetching admin details by ID: $e");
      Get.snackbar('Error', 'Failed to fetch admin details by ID');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new user
  // Future<void> addUser(pengguna.User user) async {
  //   try {
  //     isLoading.value = true;

  //     final authResponse = await supabase.auth.signUp(
  //       email: user.userEmail,
  //       password: user.userPassword,
  //     );

  //     final uid = authResponse.user?.id;

  //     if (uid == null) {
  //       throw Exception(
  //         "User ID is null after sign-up. Email may already be in use.",
  //       );
  //     }

  //     final userWithId = user.copyWith(userId: uid.substring(0, 8));
  //     await supabase.from('users').insert(userWithId.toJson());

  //     Get.snackbar(
  //       "Berjaya",
  //       "Maklumat ahli baru telah disimpan.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       snackStyle: SnackStyle.FLOATING,
  //     );
  //   } catch (e) {
  //     print("Error adding user: $e");
  //     Get.snackbar(
  //       'Ralat',
  //       e.toString(),
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  // Use auth Controller to add user

  // Update an existing user
  Future<void> updateUser(pengguna.User user) async {
    try {
      isLoading.value = true;
      await supabase
          .from('users')
          .update(user.toJson())
          .eq('user_id', user.userId.toString());
      Get.snackbar('Success', 'User updated');
    } catch (e) {
      print("Error updating user: $e");
      Get.snackbar('Error', 'Failed to update user');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    final String supabaseUrl =
        'https://djeeipnokclsjabwadoq.supabase.co/functions/v1/delete-user'; // Replace with your Supabase function URL

    try {
      isLoading.value = true;

      // Load the environment variables first (in case onInit() is not called at the correct time)
      await dotenv.load(fileName: ".env");
      print(dotenv.env); // To see all loaded environment variables

      // Fetch the service role key from .env
      var key = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
      if (key == null || key.isEmpty) {
        throw Exception('Service Role Key not found in .env file');
      }

      print("Deleting user with ID: $userId");
      print("Supabase URL: $supabaseUrl");

      final response = await http.delete(
        Uri.parse(supabaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key', // Add the service role key here
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        print('User deleted successfully');
        Get.snackbar('Success', 'User deleted');
      } else {
        print('Error: ${response.body}');
        Get.snackbar('Error', 'Failed to delete user');
      }
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar('Error', 'Failed to delete user');
    } finally {
      isLoading.value = false;
    }
  }

  // Stream real-time updates for the 'users' table
  void listenForRealTimeUpdates() {
    supabase
        .from('users') // Target the 'users' table
        .stream(primaryKey: ['user_id']) // Stream based on primary key
        .listen((List<Map<String, dynamic>> changes) {
          // On any changes (insert, update, delete), we will update the user list
          if (changes.isNotEmpty) {
            // Handle changes (inserts, updates, deletes)

            // You can update users in a more customized way here if needed
            fetchUsers(); // Fetch the latest users from the database
          }
        });
  }

  Stream<List<Map<String, dynamic>>> streamProfileByUserID(String userID) {
    return supabase
        .from('users')
        .stream(primaryKey: ['user_id']) // Use primary key to track changes
        .eq('user_id', userID);
  }

  // Sign out the user
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Add this method to the UserController class
  Map<int, int> getRegistrationsByYear() {
    Map<int, int> yearCounts = {};

    for (var user in users) {
      final year = user.userCreatedAt.year;
      yearCounts[year] = (yearCounts[year] ?? 0) + 1;
    }

    // Make sure all years have a value, even if zero
    final currentYear = DateTime.now().year;
    for (int year = currentYear - 3; year <= currentYear; year++) {
      yearCounts.putIfAbsent(year, () => 0);
    }

    return yearCounts;
  }
}
