import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TuntutanController extends GetxController {
  // Reactive list to store claims
  var tuntutanList = <ClaimModel>[].obs;
  var selectedTuntutan = Rxn<ClaimModel>();

  // Loading state
  var isLoading = false.obs;

  // Supabase client instance
  final supabase = Supabase.instance.client;

  // Method to set tuntutan
  void setTuntutan(ClaimModel newselectedTuntutan) {
    selectedTuntutan.value = newselectedTuntutan;
  }

  // Method to get tuntutan
  ClaimModel? getTuntutan() {
    return selectedTuntutan.value;
  }

  // Fetch claims from Supabase
  Future<void> fetchTuntutan() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('claims')
          .select('''
          *,
          users (*)
        ''')
          .order('claim_created_at', ascending: true);

      // print("Response: $response");

      tuntutanList.assignAll(
        (response as List).map((data) => ClaimModel.fromJson(data)).toList(),
      );
    } catch (e) {
      print("Error fetching tuntutan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new claim to Supabase
  Future<void> addTuntutan(ClaimModel tuntutan) async {
    try {
      final response = await supabase.from('claims').insert(tuntutan.toJson());
      if (response != null) {
        fetchTuntutan(); // Refresh the list after adding
      }
    } catch (e) {
      print("Error adding tuntutan: $e");
    }
  }

  // Update an existing claim in Supabase
  Future<void> updateTuntutan(ClaimModel updatedTuntutan) async {
    try {
      final response =
          await supabase
              .from('claims')
              .update({
                'claim_overallStatus': updatedTuntutan.claimOverallStatus,
                'claim_type': updatedTuntutan.claimType,
                'claim_updated_at':
                    updatedTuntutan.claimUpdatedAt.toIso8601String(),
              })
              .eq('claim_id', updatedTuntutan.claimId.toString())
              .select()
              .single();

      if (response != null) {
        await fetchTuntutan(); // Refresh the list after updating
        Get.snackbar(
          'Berjaya',
          'Tuntutan telah dikemaskini',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print("Error updating claim line: $e");
      Get.snackbar(
        'Ralat',
        'Gagal mengemaskini tuntutan',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Delete a claim from Supabase
  Future<void> deleteTuntutan(int claimId) async {
    try {
      final response = await supabase
          .from('claims')
          .delete()
          .eq('claim_id', claimId);

      if (response != null) {
        fetchTuntutan(); // Refresh the list after deleting
      }
    } catch (e) {
      print("Error deleting tuntutan: $e");
    }
  }

  // Find a claim by ID (local search)
  ClaimModel? findTuntutanById(int claimId) {
    return tuntutanList.firstWhereOrNull(
      (tuntutan) => tuntutan.claimId == claimId,
    );
  }
}
