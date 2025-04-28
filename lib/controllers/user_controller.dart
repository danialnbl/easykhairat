import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/userModel.dart' as pengguna;

class UserController extends GetxController {
  var users = <pengguna.User>[].obs; // RxList to hold users
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

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

  // Add a new user
  Future<void> addUser(pengguna.User user) async {
    try {
      isLoading.value = true;
      await supabase.from('users').insert(user.toJson());
      Get.snackbar('Success', 'User added');
    } catch (e) {
      print("Error adding user: $e");
      Get.snackbar('Error', 'Failed to add user');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing user
  Future<void> updateUser(pengguna.User user) async {
    try {
      isLoading.value = true;
      await supabase
          .from('users')
          .update(user.toJson())
          .eq('user_id', user.userId);
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
    try {
      isLoading.value = true;
      await supabase.from('users').delete().eq('user_id', userId);
      Get.snackbar('Success', 'User deleted');
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
            print("Real-time data changed: $changes");
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
}
