import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/claimLineModel.dart';

class ClaimLineController extends GetxController {
  // Reactive list to store claim lines
  var claimLineList = <ClaimLineModel>[].obs;
  // Reactive list to store claim lines by claim ID
  var claimLineListByClaimId = <ClaimLineModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Supabase client instance
  final supabase = Supabase.instance.client;

  // Fetch claim lines from Supabase
  Future<void> fetchClaimLines() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('claim_line')
          .select()
          .order('claimLine_created_at', ascending: false);

      print("Response: $response");

      claimLineList.assignAll(
        (response as List)
            .map((data) => ClaimLineModel.fromJson(data))
            .toList(),
      );
    } catch (e) {
      print("Error fetching claim lines: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new claim line to Supabase
  Future<void> addClaimLine(ClaimLineModel claimLine) async {
    try {
      final response =
          await supabase
              .from('claim_line')
              .insert(claimLine.toJson())
              .select()
              .single();

      if (response != null) {
        fetchClaimLines(); // Refresh the list after adding
      }
    } catch (e) {
      print("Error adding claim line: $e");
    }
  }

  // Update an existing claim line in Supabase
  Future<void> updateClaimLine(
    int claimLineId,
    ClaimLineModel updatedClaimLine,
  ) async {
    try {
      final response =
          await supabase
              .from('claim_line')
              .update(updatedClaimLine.toJson())
              .eq('claimLine_id', claimLineId)
              .select()
              .single();

      if (response != null) {
        fetchClaimLines(); // Refresh the list after updating
      }
    } catch (e) {
      print("Error updating claim line: $e");
    }
  }

  // Delete a claim line from Supabase
  Future<void> deleteClaimLine(int claimLineId) async {
    try {
      final response = await supabase
          .from('claim_line')
          .delete()
          .eq('claimLine_id', claimLineId);

      if (response != null) {
        fetchClaimLines(); // Refresh the list after deleting
      }
    } catch (e) {
      print("Error deleting claim line: $e");
    }
  }

  // Find a claim line by ID (local search)
  ClaimLineModel? findClaimLineById(int claimLineId) {
    return claimLineList.firstWhereOrNull(
      (claimLine) => claimLine.claimLineId == claimLineId,
    );
  }

  // Get claim lines by claim ID
  Future<List<ClaimLineModel>> getClaimLinesByClaimId(int claimId) async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('claim_line')
          .select()
          .eq('claim_id', claimId)
          .order('claimLine_created_at', ascending: false);

      print("Response claimline: $response");

      claimLineListByClaimId.assignAll(
        (response as List)
            .map((data) => ClaimLineModel.fromJson(data))
            .toList(),
      );

      return (response as List)
          .map((data) => ClaimLineModel.fromJson(data))
          .toList();
    } catch (e) {
      print("Error fetching claim lines for claim $claimId: $e");
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Update claim line status
  Future<void> updateClaimLineStatus(int claimLineId, String newStatus) async {
    try {
      final response =
          await supabase
              .from('claim_line')
              .update({'claimLine_status': newStatus})
              .eq('claimLine_id', claimLineId)
              .select()
              .single();

      if (response != null) {
        fetchClaimLines(); // Refresh the list after updating status
      }
    } catch (e) {
      print("Error updating claim line status: $e");
    }
  }
}
