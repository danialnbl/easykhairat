import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/announcementModel.dart';

class AnnouncementController extends GetxController {
  var announcements = <AnnouncementModel>[].obs;
  var selectedAnnouncement = Rxn<AnnouncementModel>();
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    listenForRealTimeUpdates();
  }

  // Fetch all announcements
  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('announcements')
          .select('''
        *,
        admin (
          admin_id
        )
      ''')
          .order('announcement_created_at', ascending: false);

      final fetchedAnnouncements =
          (response as List<dynamic>)
              .map(
                (json) =>
                    AnnouncementModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      announcements.assignAll(fetchedAnnouncements);
    } catch (e) {
      print("Error fetching announcements: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch announcements',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch announcement by ID
  Future<AnnouncementModel?> fetchAnnouncementById(int announcementId) async {
    try {
      isLoading.value = true;
      final response =
          await supabase
              .from('announcements')
              .select()
              .eq('announcement_id', announcementId)
              .single();

      if (response != null) {
        return AnnouncementModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching announcement by ID: $e");
      Get.snackbar('Error', 'Failed to fetch announcement');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Add new announcement
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      isLoading.value = true;
      await supabase.from('announcements').insert(announcement.toJson());

      Get.snackbar(
        'Success',
        'Announcement added successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      await fetchAnnouncements();
    } catch (e) {
      print("Error adding announcement: $e");
      Get.snackbar(
        'Error',
        'Failed to add announcement',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update announcement
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      isLoading.value = true;
      await supabase
          .from('announcements')
          .update(announcement.toJson())
          .eq('announcement_id', announcement.announcementId ?? 0);

      Get.snackbar(
        'Success',
        'Announcement updated successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      await fetchAnnouncements();
    } catch (e) {
      print("Error updating announcement: $e");
      Get.snackbar(
        'Error',
        'Failed to update announcement',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(int announcementId) async {
    try {
      isLoading.value = true;
      await supabase
          .from('announcements')
          .delete()
          .eq('announcement_id', announcementId);

      Get.snackbar(
        'Success',
        'Announcement deleted successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      await fetchAnnouncements();
    } catch (e) {
      print("Error deleting announcement: $e");
      Get.snackbar(
        'Error',
        'Failed to delete announcement',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Listen for real-time updates
  void listenForRealTimeUpdates() {
    supabase
        .from('announcements')
        .stream(primaryKey: ['announcement_id'])
        .listen((List<Map<String, dynamic>> changes) {
          if (changes.isNotEmpty) {
            fetchAnnouncements();
          }
        });
  }

  // Stream announcements for real-time updates
  Stream<List<Map<String, dynamic>>> streamAnnouncements() {
    return supabase
        .from('announcements')
        .stream(primaryKey: ['announcement_id'])
        .order('announcement_created_at', ascending: false);
  }

  void setSelectedAnnouncement(AnnouncementModel announcement) {
    selectedAnnouncement.value = announcement;
  }

  AnnouncementModel? getSelectedAnnouncement() {
    return selectedAnnouncement.value;
  }
}
