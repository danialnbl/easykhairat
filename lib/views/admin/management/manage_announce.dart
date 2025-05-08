import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/widgets/header.dart';

class ManageAnnounce extends StatefulWidget {
  const ManageAnnounce({Key? key}) : super(key: key);

  @override
  _ManageAnnounceState createState() => _ManageAnnounceState();
}

class _ManageAnnounceState extends State<ManageAnnounce> {
  final TextEditingController titleSearchController = TextEditingController();
  final TextEditingController dateSearchController = TextEditingController();
  RxString selectedFilter = 'All Announcements'.obs;

  // Mock data for announcements
  final List<Map<String, String>> announcements = [
    {
      'id': '1',
      'title': 'Meeting Announcement',
      'date': '01/05/2025',
      'description': 'Monthly meeting for all members.',
    },
    {
      'id': '2',
      'title': 'Event Update',
      'date': '03/05/2025',
      'description': 'Details about the upcoming charity event.',
    },
  ];

  // Filter announcements based on search text and selected filter
  List<Map<String, String>> getFilteredAnnouncements() {
    return announcements.where((announcement) {
      bool matchesTitle =
          titleSearchController.text.isEmpty ||
          announcement['title']!.toLowerCase().contains(
            titleSearchController.text.toLowerCase(),
          );

      bool matchesDate =
          dateSearchController.text.isEmpty ||
          announcement['date']!.toLowerCase().contains(
            dateSearchController.text.toLowerCase(),
          );

      return matchesTitle && matchesDate;
    }).toList();
  }

  void viewAnnouncement(Map<String, String> announcement) {
    debugPrint("View tapped for ${announcement['title']}");
    // Implement view functionality
  }

  void deleteAnnouncement(Map<String, String> announcement) {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${announcement['title']}?',
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              setState(() {
                announcements.remove(announcement);
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final filteredAnnouncements = getFilteredAnnouncements();

    if (filteredAnnouncements.isEmpty) {
      return const Center(child: Text('No announcements found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // ID
          1: FlexColumnWidth(3), // Title
          2: FlexColumnWidth(2), // Date
          3: FlexColumnWidth(4), // Description
          4: FlexColumnWidth(2), // Actions
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: MoonColors.light.roshi),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Data rows
          ...filteredAnnouncements.map((announcement) {
            return TableRow(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    announcement['id']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    announcement['title']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    announcement['date']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    announcement['description']!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () => viewAnnouncement(announcement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteAnnouncement(announcement),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleSearchController,
                    decoration: InputDecoration(
                      hintText: "Search by Title...",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: dateSearchController,
                    decoration: InputDecoration(
                      hintText: "Search by Date...",
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<String>(
                    value: selectedFilter.value,
                    items:
                        ['All Announcements', 'Important', 'General']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
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
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }
}
