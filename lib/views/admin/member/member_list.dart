import 'package:easykhairat/views/admin/components/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  MemberListState createState() => MemberListState();
}

class MemberListState extends State<MemberList> {
  final UserController userController = Get.put(UserController());
  TextEditingController searchController = TextEditingController();
  RxString selectedFilter = 'All'.obs;

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
      // Check if user matches search query
      bool matchesSearch =
          searchController.text.isEmpty ||
          user.userName.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          user.userIdentification.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          user.userPhoneNo.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          user.userAddress.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          user.userEmail.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          user.userType.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      // Check if user matches selected filter
      bool matchesFilter =
          selectedFilter.value == 'All' ||
          user.userType == selectedFilter.value;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void viewMember(dynamic user) {
    debugPrint("View tapped for ${user.userName}");
    // Add functionality to display member details in a dialog or new screen
    Get.dialog(
      AlertDialog(
        title: Text('User Details: ${user.userName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Name', user.userName),
              _detailRow('IC Number', user.userIdentification),
              _detailRow('Phone', user.userPhoneNo),
              _detailRow('Email', user.userEmail),
              _detailRow('Address', user.userAddress),
              _detailRow('Type', user.userType),
              _detailRow('Created At', formatDate(user.userCreatedAt)),
              _detailRow('Updated At', formatDate(user.userUpdatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Close'), onPressed: () => Get.back()),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void editMember(dynamic user) {
    debugPrint("Edit tapped for ${user.userName}");
    // Navigate to edit screen or show edit dialog
    // This is a placeholder - implement actual navigation/edit functionality
    Get.toNamed('/edit-member', arguments: user);
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
              userController.deleteUser(
                user.userId,
              ); // Implement this method in your controller
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Obx(() {
      final filteredUsers = getFilteredUsers(); // This handles filtering

      if (userController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (filteredUsers.isEmpty) {
        return const Center(child: Text('No members found'));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Card(
          color: MoonColors.light.goten,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FixedColumnWidth(150),
                1: FixedColumnWidth(120),
                2: FixedColumnWidth(120),
                3: FixedColumnWidth(180),
                4: FixedColumnWidth(100),
                5: FixedColumnWidth(180),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: MoonColors.light.goten.withOpacity(0.7),
                  ),
                  children: const [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Nama',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'IC Baru',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Tarikh Daftar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Alamat',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                // Data Rows
                ...List.generate(filteredUsers.length, (index) {
                  final user = filteredUsers[index];
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.userName),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.userIdentification),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(formatDate(user.userCreatedAt)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.userAddress),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.userType),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.green,
                                ),
                                onPressed: () => viewMember(user),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => editMember(user),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteMember(user),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search member...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild with new search text
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<String>(
                    value: selectedFilter.value,
                    items:
                        ['All', 'Active', 'Inactive']
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add member screen
          Get.toNamed('/add-member');
        },
        backgroundColor: MoonColors.light.piccolo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
