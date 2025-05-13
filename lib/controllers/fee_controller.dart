import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/feeModel.dart';

class FeeController extends GetxController {
  var yuranTertunggak = <FeeModel>[].obs;
  var yuranGeneral = <FeeModel>[].obs;
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // fetchFees();
    listenForRealTimeUpdates();
  }

  // Fetch all fees
  Future<void> fetchFees() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('fees')
          .select(
            '*, users(*)',
          ); // Join fees table with users table using user_id

      // Debug the raw response from Supabase
      // print("Response from Supabase: $response");

      final fetchedFees =
          (response as List<dynamic>)
              .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
              .toList();

      // Debug the fetched fees
      // print("Fetched fees: $fetchedFees");

      yuranGeneral.assignAll(fetchedFees);
    } catch (e) {
      print("Error fetching fees: $e");
      Get.snackbar('Error', 'Failed to fetch fees');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch fees by user ID
  Future<void> fetchYuranTertunggak(String userId) async {
    if (userId == null || userId.isEmpty) {
      Get.snackbar('Error', 'User ID is invalid');
      return; // Avoid making a query if the user ID is invalid
    }

    try {
      isLoading.value = true;

      // Debug the user ID being used
      print("Fetching fees for user ID: $userId with status Tertunggak");

      final response = await supabase
          .from('fees')
          .select()
          .eq('user_id', userId) // Ensures filtering by user_id
          .eq('fee_status', 'Tertunggak'); // Ensures filtering by fee_status

      // Debug the raw response from Supabase
      // print("Response from Supabase: $response");

      // Handle the case where the response might not be in the expected format
      if (response is List) {
        final fetchedFees =
            (response as List<dynamic>)
                .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
                .toList();

        yuranTertunggak.assignAll(fetchedFees);
      } else {
        print("Unexpected response format: $response");
        Get.snackbar('Error', 'Unexpected response format');
      }
    } catch (e) {
      print("Error fetching fees by user ID and status: $e");
      Get.snackbar('Error', 'Failed to fetch fees');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new fee
  Future<void> addFee(FeeModel fee) async {
    try {
      isLoading.value = true;
      await supabase.from('fees').insert(fee.toJson());
      Get.snackbar(
        'Berjaya',
        'Maklumat yuran telah disimpan.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding fee: $e");
      Get.snackbar('Error', 'Failed to add fee');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a fee
  Future<void> updateFee(FeeModel fee, String fee_id) async {
    try {
      isLoading.value = true;

      // Update the feeUpdatedAt field to the current time
      final updatedFee = fee.copyWith(feeUpdatedAt: DateTime.now());

      // Send the updated fee data to Supabase
      await supabase
          .from('fees')
          .update(updatedFee.toJson())
          .eq('fee_id', fee_id);

      Get.snackbar(
        'Success',
        'Fee updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log("Error updating fee: $e");
      Get.snackbar('Error', 'Failed to update fee');
    } finally {
      isLoading.value = false;
    }
  }

  // Update fee status
  Future<void> updateFeeStatus(int feeId, String status) async {
    try {
      isLoading.value = true;
      await supabase
          .from('fees')
          .update({'fee_status': status})
          .eq('fee_id', feeId);
      Get.snackbar('Success', 'Fee status updated');
    } catch (e) {
      print("Error updating fee status: $e");
      Get.snackbar('Error', 'Failed to update fee status');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a fee
  Future<void> deleteFee(int feeId) async {
    try {
      isLoading.value = true;
      // Check if feeId is valid
      print("Deleting fee with ID: $feeId");
      await supabase.from('fees').delete().eq('fee_id', feeId);
      Get.snackbar('Success', 'Fee deleted');
    } catch (e) {
      print("Error deleting fee: $e");
      Get.snackbar('Error', 'Failed to delete fee');
    } finally {
      isLoading.value = false;
    }
  }

  // Listen for real-time updates
  void listenForRealTimeUpdates() {
    supabase.from('fees').stream(primaryKey: ['fee_id']).listen((
      List<Map<String, dynamic>> changes,
    ) {
      if (changes.isNotEmpty) {
        fetchFees(); // Refresh list when any change happens
      }
    });
  }

  // Stream fees by user ID (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamFeesByUserId(String userId) {
    return supabase
        .from('fees')
        .stream(primaryKey: ['fee_id'])
        .eq('user_id', userId);
  }
}
