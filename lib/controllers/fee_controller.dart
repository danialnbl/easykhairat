import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/feeModel.dart';

class FeeController extends GetxController {
  var yuranTertunggak = <FeeModel>[].obs;
  var yuranGeneral = <FeeModel>[].obs;
  var selectedYuran = Rxn<FeeModel>();
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    listenForRealTimeUpdates();
  }

  // Fetch all fees
  Future<void> fetchFees() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('fees').select('*');

      final fetchedFees =
          (response as List<dynamic>)
              .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
              .toList();

      yuranGeneral.assignAll(fetchedFees);
    } catch (e) {
      print("Error fetching fees: $e");
      Get.snackbar('Error', 'Failed to fetch fees');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch fees by user ID that don't have payments yet (tertunggak/outstanding)
  Future<void> fetchYuranTertunggak(String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID is invalid');
      return;
    }

    try {
      isLoading.value = true;
      print("Fetching outstanding fees for user ID: $userId");

      // First get all fees
      final allFeesResponse = await supabase.from('fees').select('''
            fee_id,
            fee_description,
            fee_due,
            fee_type,
            fee_created_at,
            fee_updated_at,
            admin_id,
            fee_amount
          ''');

      // Then get all fee IDs that have been paid by this user
      final paidFeesResponse = await supabase
          .from('payments')
          .select('fee_id')
          .eq('user_id', userId)
          .not('fee_id', 'is', null);

      if (allFeesResponse is List && paidFeesResponse is List) {
        final allFees =
            (allFeesResponse as List<dynamic>)
                .map((json) => FeeModel.fromJson(json as Map<String, dynamic>))
                .toList();

        final paidFeeIds =
            (paidFeesResponse as List<dynamic>)
                .map((payment) => payment['fee_id'] as int)
                .toSet();

        // Filter out fees that have been paid by this user
        final outstandingFees =
            allFees
                .where(
                  (fee) => fee.feeId != null && !paidFeeIds.contains(fee.feeId),
                )
                .toList();

        yuranTertunggak.assignAll(outstandingFees);
        print(
          "Found ${outstandingFees.length} outstanding fees for user $userId",
        );
      } else {
        print("Unexpected response format");
        Get.snackbar('Error', 'Unexpected response format');
      }
    } catch (e) {
      print("Error fetching outstanding fees: $e");
      Get.snackbar('Error', 'Failed to fetch outstanding fees');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new fee
  Future<void> addFee(FeeModel fee) async {
    try {
      isLoading.value = true;
      await supabase.from('fees').insert(fee.toJson());
      await fetchFees(); // Refresh the list
      Get.snackbar(
        'Berjaya',
        'Maklumat yuran telah disimpan.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding fee: $e");
      Get.snackbar('Error', 'Failed to add fee: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a fee
  Future<void> updateFee(FeeModel fee) async {
    try {
      isLoading.value = true;

      if (fee.feeId == null) {
        throw Exception('Fee ID cannot be null for update operation');
      }

      final updateData = {
        'fee_description': fee.feeDescription,
        'fee_due': fee.feeDue.toIso8601String(),
        'fee_type': fee.feeType,
        'fee_updated_at': DateTime.now().toIso8601String(),
        'admin_id': fee.adminId,
        'fee_amount': fee.feeAmount,
      };

      print("Updating fee with ID: ${fee.feeId} and data: $updateData");

      await supabase.from('fees').update(updateData).eq('fee_id', fee.feeId!);
      await fetchFees(); // Refresh the fees list

      Get.snackbar(
        'Berjaya',
        'Maklumat yuran telah dikemaskini',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating fee: $e");
      Get.snackbar(
        'Error',
        'Gagal mengemaskini yuran: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a fee
  Future<void> deleteFee(int feeId) async {
    try {
      isLoading.value = true;
      print("Deleting fee with ID: $feeId");

      await supabase.from('fees').delete().eq('fee_id', feeId);
      await fetchFees(); // Refresh the list

      Get.snackbar(
        'Berjaya',
        'Yuran telah dipadam',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting fee: $e");
      Get.snackbar('Error', 'Failed to delete fee: $e');
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

  // Set Fee
  void setFee(FeeModel fee) {
    selectedYuran.value = fee;
  }

  // Get Fee
  FeeModel? getFee() {
    return selectedYuran.value;
  }

  // Clear selected fee
  void clearSelectedFee() {
    selectedYuran.value = null;
  }

  // Get fees by type
  List<FeeModel> getFeesByType(String feeType) {
    return yuranGeneral.where((fee) => fee.feeType == feeType).toList();
  }

  // Get overdue fees (fees past due date)
  List<FeeModel> getOverdueFees() {
    final now = DateTime.now();
    return yuranGeneral.where((fee) => fee.feeDue.isBefore(now)).toList();
  }
}
