import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/controllers/claimline_controller.dart'; // Add this import

class TuntutanController extends GetxController {
  // Reactive list to store claims
  var tuntutanList = <ClaimModel>[].obs;
  var selectedTuntutan = Rxn<ClaimModel>();

  // Loading state
  var isLoading = false.obs;

  // Map to store claim line totals for each claim
  var claimTotals = <int, double>{}.obs;

  // Supabase client instance
  final supabase = Supabase.instance.client;
  // Reference to ClaimLineController
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );

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

      // After fetching claims, fetch totals for each claim
      await fetchClaimTotals();
    } catch (e) {
      print("Error fetching tuntutan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // New method to fetch totals for each claim
  Future<void> fetchClaimTotals() async {
    try {
      // Clear existing totals
      claimTotals.clear();

      for (var claim in tuntutanList) {
        if (claim.claimId != null) {
          // Get claim lines for this claim
          final claimLines = await claimLineController.getClaimLinesByClaimId(
            claim.claimId!,
          );

          // Calculate total
          double total = 0;
          for (var line in claimLines) {
            total += line.claimLineTotalPrice;
          }

          // Store total for this claim
          claimTotals[claim.claimId!] = total;
        }
      }
    } catch (e) {
      print("Error fetching claim totals: $e");
    }
  }

  // Get claim total for a specific claim
  double getClaimTotal(int claimId) {
    return claimTotals[claimId] ?? 0.0;
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
                'claim_reason':
                    updatedTuntutan.claimReason, // Added claim_reason
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
      isLoading(true);

      // Delete from Supabase
      final response = await supabase
          .from('claims')
          .delete()
          .eq('claim_id', claimId);

      // Remove the deleted claim from the list
      tuntutanList.removeWhere((claim) => claim.claimId == claimId);

      Get.snackbar(
        'Berjaya',
        'Tuntutan telah dipadamkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Ralat',
        'Gagal memadam tuntutan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // Find a claim by ID (local search)
  ClaimModel? findTuntutanById(int claimId) {
    return tuntutanList.firstWhereOrNull(
      (tuntutan) => tuntutan.claimId == claimId,
    );
  }

  // Updated to include claim_reason
  Future<ClaimModel?> createTuntutan({
    required String userId,
    required String claimType,
    String? certificateUrl, // Add this parameter
  }) async {
    try {
      final response =
          await supabase
              .from('claims')
              .insert({
                'user_id': userId,
                'claim_type': claimType,
                'claim_overallStatus': 'Dalam Proses',
                'claim_certificate_url':
                    certificateUrl, // Include certificate URL
                'claim_created_at': DateTime.now().toIso8601String(),
                'claim_updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      // Create a claim model from the response
      final createdClaim = ClaimModel.fromJson(response);

      // Refresh the tuntutan list
      await fetchTuntutan();

      return createdClaim;
    } catch (e) {
      print('Error creating tuntutan: $e');
      Get.snackbar(
        'Error',
        'Failed to create claim: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
      );
      return null;
    }
  }

  // New method to update claim reason
  Future<void> updateClaimReason(int claimId, String reason) async {
    try {
      final response =
          await supabase
              .from('claims')
              .update({
                'claim_reason': reason,
                'claim_updated_at': DateTime.now().toIso8601String(),
              })
              .eq('claim_id', claimId.toString())
              .select()
              .single();

      if (response != null) {
        await fetchTuntutan(); // Refresh the list after updating
        Get.snackbar(
          'Berjaya',
          'Sebab tuntutan telah dikemaskini',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print("Error updating claim reason: $e");
      Get.snackbar(
        'Ralat',
        'Gagal mengemaskini sebab tuntutan',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  Future<bool> updateClaimCertificate(
    int claimId,
    String certificateUrl,
  ) async {
    try {
      final response =
          await supabase
              .from('claims')
              .update({
                'claim_certificate_url': certificateUrl,
                'claim_updated_at': DateTime.now().toIso8601String(),
              })
              .eq('claim_id', claimId)
              .select()
              .single();

      return true;
    } catch (e) {
      print('Error updating claim certificate: $e');
      return false;
    }
  }
}
