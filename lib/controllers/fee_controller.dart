import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/feeModel.dart';

class FeeController extends GetxController {
  var fees = <FeeModel>[].obs;
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchFees();
    listenForRealTimeUpdates();
  }

  // Fetch all fees
  Future<void> fetchFees() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('fees')
          .select()
          .or('user_id.is.null');

      final fetchedFees =
          (response as List<dynamic>)
              .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
              .toList();

      fees.assignAll(fetchedFees);
    } catch (e) {
      print("Error fetching fees: $e");
      Get.snackbar('Error', 'Failed to fetch fees');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchYuranByID(String userId) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('fees')
          .select()
          .eq('user_id', userId); // Filter by user_id

      final fetchedFees =
          (response as List<dynamic>)
              .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
              .toList();

      print(fetchedFees);

      fees.assignAll(fetchedFees);
    } catch (e) {
      print("Error fetching fees: $e");
      Get.snackbar('Error', 'Failed to fetch fees');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch fees by user ID
  Future<void> fetchFeesByUserId(String userId) async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('fees')
          .select()
          .eq('user_id', userId);

      final fetchedFees =
          (response as List<dynamic>)
              .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
              .toList();

      fees.assignAll(fetchedFees);
    } catch (e) {
      print("Error fetching fees by user ID: $e");
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
      Get.snackbar('Success', 'Fee added');
    } catch (e) {
      print("Error adding fee: $e");
      Get.snackbar('Error', 'Failed to add fee');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a fee
  Future<void> updateFee(FeeModel fee) async {
    try {
      isLoading.value = true;
      // final updatedFee = fee.copyWith(
      //   feeUpdatedAt: DateTime.now(), // Update only updatedAt field
      // );

      await supabase.from('fees').update(fee.toJson()).eq('fee_id', fee.feeId);

      Get.snackbar('Success', 'Fee updated');
    } catch (e) {
      Get.log("Error updating fee: $e");
      Get.snackbar('Error', 'Failed to update fee');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a fee
  Future<void> deleteFee(int feeId) async {
    try {
      isLoading.value = true;
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
