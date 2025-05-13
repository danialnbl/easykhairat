import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:intl/intl.dart';

class ProsesYuran extends StatefulWidget {
  const ProsesYuran({super.key});

  @override
  ProsesYuranState createState() => ProsesYuranState();
}

class ProsesYuranState extends State<ProsesYuran> {
  final UserController userController = Get.put(UserController());
  final NavigationController navController = Get.put(NavigationController());
  final FeeController feeController = Get.put(FeeController());
  final PaymentController paymentController = Get.put(PaymentController());
  RxString selectedFilter = 'Semua'.obs;
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController icSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users if needed
    if (userController.normalusers.isEmpty) {
      userController.fetchNormal();
    }
    // Fetch fees if needed
    if (feeController.yuranGeneral.isEmpty) {
      feeController.fetchFees();
    }
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Filter users based on search text and selected filter
  List<dynamic> getFilteredUsers() {
    return userController.normalusers.where((user) {
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
          selectedFilter.value == 'Semua' ||
          (selectedFilter.value == 'Tertunggak' &&
              feeController.yuranGeneral.any(
                (fee) =>
                    fee.feeStatus == 'Tertunggak' && fee.userId == user.userId,
              )) ||
          (selectedFilter.value == 'Selesai' &&
              !feeController.yuranGeneral.any(
                (fee) =>
                    fee.feeStatus == 'Tertunggak' && fee.userId == user.userId,
              ));

      return matchesName && matchesIC && matchesFilter;
    }).toList();
  }

  Widget _buildTable() {
    return Obx(() {
      final filteredUsers = getFilteredUsers();

      if (userController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (filteredUsers.isEmpty) {
        return const Center(child: Text('No members found'));
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2), // User ID
            1: FlexColumnWidth(2), // Name
            2: FlexColumnWidth(2), // IC Baru
            3: FlexColumnWidth(3), // Alamat
            4: FlexColumnWidth(2), // Status Bayaran
            5: FlexColumnWidth(2), // Actions
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
                    'User ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Nama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'IC Baru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Alamat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'Status Bayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
            ...filteredUsers.map((user) {
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
                      user.userId.substring(0, 8),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      user.userName,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      user.userIdentification,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      user.userAddress,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (feeController.yuranGeneral.any(
                            (fee) =>
                                fee.feeStatus == 'Tertunggak' &&
                                fee.userId == user.userId,
                          ))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Tertunggak',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            feeController.fetchYuranTertunggak(user.userId);
                            paymentController.fetchPaymentsByUserId(
                              user.userId,
                            );
                            navController.setUser(user);
                            navController.changeIndex(9);
                          },
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
            AppHeader(title: "Proses Yuran", notificationCount: 3),
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
                      MoonBreadcrumbItem(label: Text("Kewangan")),
                      MoonBreadcrumbItem(label: Text("Proses Yuran")),
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
                    controller: nameSearchController,
                    decoration: InputDecoration(
                      hintText: "Search by Name...",
                      prefixIcon: const Icon(Icons.person),
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
                    controller: icSearchController,
                    decoration: InputDecoration(
                      hintText: "Search by IC...",
                      prefixIcon: const Icon(Icons.badge),
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
                        ['Semua', 'Selesai', 'Tertunggak']
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
