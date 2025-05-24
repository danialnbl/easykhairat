import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:easykhairat/controllers/announcement_controller.dart';
import 'package:easykhairat/models/announcementModel.dart';
import 'package:intl/intl.dart';

class ManageAnnounce extends StatefulWidget {
  const ManageAnnounce({Key? key}) : super(key: key);

  @override
  _ManageAnnounceState createState() => _ManageAnnounceState();
}

class _ManageAnnounceState extends State<ManageAnnounce> {
  final TextEditingController titleSearchController = TextEditingController();
  final TextEditingController dateSearchController = TextEditingController();
  final AnnouncementController announcementController = Get.put(
    AnnouncementController(),
  );
  final NavigationController navigationController = Get.find();
  RxString selectedFilter = 'All Announcements'.obs;

  @override
  void initState() {
    super.initState();
    announcementController.fetchAnnouncements();
  }

  List<AnnouncementModel> getFilteredAnnouncements() {
    return announcementController.announcements.where((announcement) {
      bool matchesTitle =
          titleSearchController.text.isEmpty ||
          announcement.announcementTitle.toLowerCase().contains(
            titleSearchController.text.toLowerCase(),
          );

      bool matchesDate =
          dateSearchController.text.isEmpty ||
          DateFormat('dd/MM/yyyy')
              .format(announcement.announcementCreatedAt)
              .toLowerCase()
              .contains(dateSearchController.text.toLowerCase());

      bool matchesType =
          selectedFilter.value == 'All Announcements' ||
          announcement.announcementType == selectedFilter.value;

      return matchesTitle && matchesDate && matchesType;
    }).toList();
  }

  void deleteAnnouncement(AnnouncementModel announcement) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${announcement.announcementTitle}?',
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              announcementController.deleteAnnouncement(
                announcement.announcementId!,
              );
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  // Enhanced search widget similar to proses_tuntutan
  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Search & Filter Announcements",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            // Title search
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.title, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: titleSearchController,
                        decoration: InputDecoration(
                          hintText: "Search by title...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            // Date search
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: dateSearchController,
                        decoration: InputDecoration(
                          hintText: "Search by date...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            // Filter dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => DropdownButton<String>(
                  value: selectedFilter.value,
                  underline: SizedBox(),
                  items:
                      ['All Announcements', 'Important', 'General']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedFilter.value = value;
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton(
              onPressed: () {
                announcementController.fetchAnnouncements();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text("Refresh"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the announcements list in card format similar to proses_tuntutan
  Widget _buildAnnouncementsCards() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Announcement List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                MoonButton(
                  leading: const Icon(
                    MoonIcons.files_add_text_16_light,
                    color: Colors.white,
                  ),
                  buttonSize: MoonButtonSize.md,
                  onTap: () {
                    navigationController.selectedIndex.value = 14;
                  },
                  label: const Text(
                    'Add Announcement',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: MoonColors.light.roshi,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (announcementController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final filteredAnnouncements = getFilteredAnnouncements();

                if (filteredAnnouncements.isEmpty) {
                  return Center(
                    child: Text(
                      "No announcements found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];

                    Color typeColor = Colors.grey;
                    IconData typeIcon = Icons.announcement;

                    if (announcement.announcementType == 'Important') {
                      typeColor = Colors.red;
                      typeIcon = Icons.priority_high;
                    } else if (announcement.announcementType == 'General') {
                      typeColor = Colors.blue;
                      typeIcon = Icons.info;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.campaign, color: Colors.blue),
                        ),
                        title: Text(
                          "ID: ${announcement.announcementId} - ${announcement.announcementTitle}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Created on: ${DateFormat('dd/MM/yyyy').format(announcement.announcementCreatedAt)}",
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(typeIcon, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    announcement.announcementType,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.green),
                              onPressed: () {
                                navigationController.selectedIndex.value = 15;
                                announcementController.setSelectedAnnouncement(
                                  announcement,
                                );
                              },
                              tooltip: "View Announcement",
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteAnnouncement(announcement),
                              tooltip: "Delete Announcement",
                            ),
                          ],
                        ),
                        onTap: () {
                          navigationController.selectedIndex.value = 15;
                          announcementController.setSelectedAnnouncement(
                            announcement,
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(title: "Manage Announcements", notificationCount: 3),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: MoonColors.light.goku,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MoonBreadcrumb(
                    items: [
                      MoonBreadcrumbItem(
                        label: Text("Home"),
                        onTap: () => Get.toNamed('/adminMain'),
                      ),
                      MoonBreadcrumbItem(label: Text("Management")),
                      MoonBreadcrumbItem(label: Text("Announcements")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildAnnouncementsCards()),
          ],
        ),
      ),
    );
  }
}
