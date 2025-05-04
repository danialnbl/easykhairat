import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/familyModel.dart';

class FamilyController extends GetxController {
  var familyMembers = <FamilyModel>[].obs;
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    listenForRealTimeUpdates();
  }

  // Fetch all family members
  Future<void> fetchFamilyMembers() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('family').select();

      final fetchedFamilyMembers =
          (response as List<dynamic>)
              .map((json) => FamilyModel.fromJson(json as Map<String, dynamic>))
              .toList();

      familyMembers.assignAll(fetchedFamilyMembers);
    } catch (e) {
      print("Error fetching family members: $e");
      Get.snackbar('Error', 'Failed to fetch family members');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch family members by user ID
  Future<void> fetchFamilyMembersByUserId(String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID is invalid');
      return;
    }

    try {
      isLoading.value = true;
      final response = await supabase
          .from('family')
          .select()
          .eq('user_id', userId);

      final fetchedFamilyMembers =
          (response as List<dynamic>)
              .map((json) => FamilyModel.fromJson(json as Map<String, dynamic>))
              .toList();

      familyMembers.assignAll(fetchedFamilyMembers);
    } catch (e) {
      print("Error fetching family members by user ID: $e");
      Get.snackbar('Error', 'Failed to fetch family members');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new family member
  Future<void> addFamilyMember(FamilyModel familyMember) async {
    try {
      isLoading.value = true;
      await supabase.from('family').insert(familyMember.toJson());
      Get.snackbar('Success', 'Family member added');
    } catch (e) {
      print("Error adding family member: $e");
      Get.snackbar('Error', 'Failed to add family member');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a family member
  Future<void> updateFamilyMember(FamilyModel familyMember) async {
    try {
      isLoading.value = true;
      await supabase
          .from('family')
          .update(familyMember.toJson())
          .eq('family_id', familyMember.familyId ?? 0);

      Get.snackbar('Success', 'Family member updated');
    } catch (e) {
      print("Error updating family member: $e");
      Get.snackbar('Error', 'Failed to update family member');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a family member
  Future<void> deleteFamilyMember(int familyId) async {
    try {
      isLoading.value = true;
      await supabase.from('family').delete().eq('family_id', familyId);
      Get.snackbar('Success', 'Family member deleted');
    } catch (e) {
      print("Error deleting family member: $e");
      Get.snackbar('Error', 'Failed to delete family member');
    } finally {
      isLoading.value = false;
    }
  }

  // Listen for real-time updates
  void listenForRealTimeUpdates() {
    supabase.from('family').stream(primaryKey: ['family_id']).listen((
      List<Map<String, dynamic>> changes,
    ) {
      if (changes.isNotEmpty) {
        fetchFamilyMembers();
      }
    });
  }

  // Stream family members by user ID (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamFamilyMembersByUserId(
    String userId,
  ) {
    return supabase
        .from('family')
        .stream(primaryKey: ['family_id'])
        .eq('user_id', userId);
  }
}
