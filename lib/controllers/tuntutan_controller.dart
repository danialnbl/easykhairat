import 'package:get/get.dart';
import 'package:easykhairat/models/tuntutanModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TuntutanController extends GetxController {
  // Reactive list to store claims
  var tuntutanList = <ClaimModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Supabase client instance
  final supabase = Supabase.instance.client;

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

      print("Response: $response");

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
  Future<void> updateTuntutan(int claimId, ClaimModel updatedTuntutan) async {
    try {
      final response = await supabase
          .from('claims')
          .update(updatedTuntutan.toJson())
          .eq('claim_id', claimId);

      if (response != null) {
        fetchTuntutan(); // Refresh the list after updating
      }
    } catch (e) {
      print("Error updating tuntutan: $e");
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
