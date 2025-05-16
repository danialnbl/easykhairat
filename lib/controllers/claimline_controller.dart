import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/claimLineModel.dart';

class ClaimLineController extends GetxController {
  // Reactive list to store claim lines
  var claimLineList = <ClaimLineModel>[].obs;
  // Reactive list to store claim lines by claim ID
  var claimLineListByClaimId = <ClaimLineModel>[].obs;

  var selectedClaimLine = Rxn<ClaimLineModel>();

  // Reactive variable to store total payments
  var totalClaimLine = 0.0.obs;

  // Loading state
  var isLoading = false.obs;

  // Supabase client instance
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    listenForRealTimeUpdates();
  }

  // Method to set selected claim line
  void setClaimLine(ClaimLineModel newSelectedClaimLine) {
    selectedClaimLine.value = newSelectedClaimLine;
  }

  // Method to get selected claim line
  ClaimLineModel? getClaimLine() {
    return selectedClaimLine.value;
  }

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
  Future<void> updateClaimLine(ClaimLineModel updatedClaimLine) async {
    try {
      final response =
          await supabase
              .from('claim_line')
              .update({
                'claimLine_reason': updatedClaimLine.claimLineReason,
                'claimLine_totalPrice': updatedClaimLine.claimLineTotalPrice,
              })
              .eq('claimLine_id', updatedClaimLine.claimLineId.toString())
              .select()
              .single();

      if (response != null) {
        await getClaimLinesByClaimId(
          updatedClaimLine.claimId ?? 0,
        ); // Refresh the list after updating
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

  Future<void> fetchTotalClaimLine() async {
    try {
      final response = await supabase
          .from('claim_line')
          .select('claimLine_totalPrice');

      double total = 0.0;
      for (var item in response) {
        total += (item['claimLine_totalPrice'] ?? 0).toDouble();
      }

      totalClaimLine.value = total;
      print("Total Claim Line: ${totalClaimLine.value}");
    } catch (e) {
      print("Error fetching total claim line: $e");
      totalClaimLine.value = 0.0;
    }
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

      // print("Response claimline: $response");

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

  // real time listener for claim line changes
  void listenForRealTimeUpdates() {
    supabase.from('claim_line').stream(primaryKey: ['claimLine_id']).listen((
      List<Map<String, dynamic>> changes,
    ) {
      if (changes.isNotEmpty) {
        fetchClaimLines(); // Refresh list when any change happens
      }
    });
  }
}
