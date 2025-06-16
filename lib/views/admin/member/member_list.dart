import 'package:easykhairat/controllers/family_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:intl/intl.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  MemberListState createState() => MemberListState();
}

class MemberListState extends State<MemberList> {
  final UserController userController = Get.put(UserController());
  final NavigationController navController = Get.put(NavigationController());
  final FamilyController familyController = Get.put(FamilyController());
  RxString selectedFilter = 'Semua Ahli'.obs;
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController icSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users if needed
    if (userController.users.isEmpty) {
      userController.fetchUsers();
    }
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Filter users based on search text and selected filter
  List<dynamic> getFilteredUsers() {
    return userController.users.where((user) {
      bool matchesName =
          nameSearchController.text.isEmpty ||
          user.userName.toLowerCase().contains(
            nameSearchController.text.toLowerCase(),
          );

      bool matchesIC =
          icSearchController.text.isEmpty ||
          user.userIdentification.toLowerCase().contains(
            icSearchController.text.toLowerCase(),
          );

      bool matchesFilter =
          selectedFilter.value == 'Semua Ahli' ||
          user.userType == selectedFilter.value.toLowerCase();

      return matchesName && matchesIC && matchesFilter;
    }).toList();
  }

  // Enhanced search widget similar to proses_yuran
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
              "Cari & Tapis Ahli",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            // Name search
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
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: nameSearchController,
                        decoration: InputDecoration(
                          hintText: "Cari mengikut nama...",
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
            // IC search
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
                    Icon(Icons.badge, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: icSearchController,
                        decoration: InputDecoration(
                          hintText: "Cari mengikut IC...",
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
                      ['Semua Ahli', 'User', 'Admin']
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
            ),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton(
              onPressed: () {
                userController.fetchUsers();
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
                child: Text("Muat Semula"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the members list in card format similar to proses_yuran
  Widget _buildMembersCards() {
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
                  "Senarai Ahli",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                MoonButton(
                  leading: const Icon(
                    MoonIcons.files_add_16_light,
                    color: Colors.white,
                  ),
                  buttonSize: MoonButtonSize.md,
                  onTap: () {
                    navController.selectedIndex.value = 2;
                  },
                  label: const Text(
                    'Tambah Ahli',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: MoonColors.light.roshi,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (userController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final filteredUsers = getFilteredUsers();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      "Tiada ahli yang ditemui.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    Color typeColor = Colors.blue;
                    IconData typeIcon = Icons.person;

                    if (user.userType == 'admin') {
                      typeColor = Colors.purple;
                      typeIcon = Icons.admin_panel_settings;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(
                          user.userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.badge, size: 14),
                                SizedBox(width: 4),
                                Text(user.userIdentification),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Daftar pada: ${formatDate(user.userCreatedAt)}",
                                ),
                              ],
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
                                    user.userType.toString().capitalizeFirst!,
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
                                viewMember(user);
                                familyController.fetchFamilyMembersByUserId(
                                  user.userId,
                                );
                              },
                              tooltip: "Lihat Maklumat",
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteMember(user),
                              tooltip: "Padam Ahli",
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          viewMember(user);
                          familyController.fetchFamilyMembersByUserId(
                            user.userId,
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

  void viewMember(dynamic user) {
    debugPrint("View tapped for ${user.userName}");
    navController.setUser(user);
    navController.selectedIndex.value = 11;
  }

  void deleteMember(dynamic user) {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.userName}?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              userController.deleteUser(user.userId);
              Get.back();
            },
          ),
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
            AppHeader(title: "Senarai Ahli", notificationCount: 3),
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
                      MoonBreadcrumbItem(label: Text("Ahli")),
                      MoonBreadcrumbItem(label: Text("Senarai Ahli")),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildMembersCards()),
          ],
        ),
      ),
    );
  }
}
