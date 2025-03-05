import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/userModel.dart' as pengguna;

class UserController extends GetxController {
  var users = <pengguna.User>[].obs;

  var profile = Rxn<Map<String, dynamic>>(); // For fetchProfileByUserID
  var isLoading = false.obs; // For fetchProfileByUserID

  final supabase = Supabase.instance.client;

  // Fetch all users from 'users' table
  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('users').select();

      final fetchedUsers =
          (response as List)
              .map(
                (json) => pengguna.User.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      users.assignAll(fetchedUsers);
    } catch (e) {
      print("Error fetching users: $e");
      Get.snackbar('Error', 'Failed to fetch users');
    }
  }

  // Add a new user
  Future<void> addUser(pengguna.User user) async {
    try {
      final response = await supabase.from('users').insert(user.toInsertJson());

      if (response.error != null) {
        throw response.error!.message;
      }

      await fetchUsers();
      Get.snackbar('Success', 'User added successfully');
    } catch (e) {
      print("Error adding user: $e");
      Get.snackbar('Error', 'Failed to add user');
    }
  }

  // Update an existing user
  Future<void> updateUser(String userId, pengguna.User updatedUser) async {
    try {
      final response = await supabase
          .from('users')
          .update(updatedUser.toInsertJson())
          .eq(
            'user_id',
            userId,
          ); // Make sure user_id column is correctly set up for UUID

      if (response.error != null) {
        throw response.error!.message;
      }

      await fetchUsers();
      Get.snackbar('Success', 'User updated successfully');
    } catch (e) {
      print("Error updating user: $e");
      Get.snackbar('Error', 'Failed to update user');
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .delete()
          .eq('user_id', userId); // Assuming user_id is UUID

      if (response.error != null) {
        throw response.error!.message;
      }

      users.removeWhere((user) => user.userId == userId);
      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      print("Error deleting user: $e");
      Get.snackbar('Error', 'Failed to delete user');
    }
  }

  // Fetch a single profile by user ID (from 'profiles' table)
  Future<bool> fetchProfileByUserID(String userID) async {
    if (userID.isEmpty) {
      Get.snackbar('Error', 'Invalid user ID');
      return false;
    }

    try {
      isLoading(true);

      final response =
          await supabase
              .from('users')
              .select()
              .eq('user_id', userID)
              .maybeSingle(); // This safely returns null if no matching row found

      if (response == null) {
        Get.snackbar('Error', 'User not found for user_id: $userID');
        profile.value = {}; // Clear profile if not found
        return false;
      }

      // If found, set profile
      profile.value = response;
      return true;
    } catch (e) {
      print("Error fetching profile: $e");
      Get.snackbar('Error', 'Failed to fetch profile');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Stream<List<Map<String, dynamic>>> streamProfileByUserID(String userID) {
    return supabase
        .from('users')
        .stream(primaryKey: ['user_id']) // Use primary key to track changes
        .eq('user_id', userID);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  void onInit() {
    super.onInit();
    // fetchUsers();
  }
}
