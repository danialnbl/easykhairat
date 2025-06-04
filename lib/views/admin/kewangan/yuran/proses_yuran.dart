import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  // Add a map to store payment status for each user
  final RxMap<String, bool> userPaymentStatus = <String, bool>{}.obs;

  // Add a map to store stream subscriptions
  final Map<String, StreamSubscription> _paymentStreams = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions
    for (var subscription in _paymentStreams.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  // Initialize data in the correct order
  Future<void> _initializeData() async {
    // First, fetch users if needed
    if (userController.normalusers.isEmpty) {
      await userController.fetchNormal();
    }

    // Fetch fees if needed
    if (feeController.yuranGeneral.isEmpty) {
      await feeController.fetchFees();
    }

    // Setup real-time monitoring for all users
    _setupRealTimePaymentMonitoring();
  }

  // Setup real-time payment monitoring for all users
  void _setupRealTimePaymentMonitoring() {
    for (var user in userController.normalusers) {
      _startRealTimeMonitoring(user.userId.toString());
    }
  }

  // Start real-time monitoring for a specific user
  void _startRealTimeMonitoring(String userId) {
    // Cancel existing subscription if any
    _paymentStreams[userId]?.cancel();

    // Listen to payments table changes for this user
    _paymentStreams[userId] = feeController.supabase
        .from('payments')
        .stream(primaryKey: ['payment_id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          print("Payment data changed for user $userId");
          _checkUserPaymentStatus(userId);
        });

    // Initial check
    _checkUserPaymentStatus(userId);
  }

  // Check if a specific user has outstanding fees
  Future<void> _checkUserPaymentStatus(String userId) async {
    try {
      print("Checking payment status for user: $userId");

      // Get outstanding fees for this user
      await feeController.fetchYuranTertunggak(userId);

      // If there are outstanding fees, user has "Tertunggak" status
      bool hasOutstandingFees = feeController.yuranTertunggak.isNotEmpty;
      userPaymentStatus[userId] = !hasOutstandingFees;

      print(
        "User $userId payment status: ${userPaymentStatus[userId] ?? false ? 'Selesai' : 'Tertunggak'}",
      );
    } catch (e) {
      print("Error checking payment status for user $userId: $e");
      userPaymentStatus[userId] = false;
    }
  }

  // Enhanced payment status widget with real-time updates
  Widget _getPaymentStatusWidget(String userId) {
    return Obx(() {
      bool? isPaid = userPaymentStatus[userId];

      if (isPaid == null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Checking...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      }

      if (isPaid) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Selesai',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Tertunggak',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      }
    });
  }

  // Add refresh button to manually refresh all statuses
  Widget _buildRefreshButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed:
            feeController.isLoading.value
                ? null
                : () {
                  userPaymentStatus.clear();
                  _setupRealTimePaymentMonitoring();
                },
        icon:
            feeController.isLoading.value
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.refresh),
        label: Text(
          feeController.isLoading.value ? 'Refreshing...' : 'Refresh Status',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
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

      // Add filter by payment status
      bool matchesFilter =
          selectedFilter.value == 'Semua' ||
          (selectedFilter.value == 'Tertunggak' &&
              userPaymentStatus[user.userId] == false) ||
          (selectedFilter.value == 'Selesai' &&
              userPaymentStatus[user.userId] == true);

      return matchesName && matchesIC && matchesFilter;
    }).toList();
  }

  // Enhanced search widget that matches your image
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
                    Icon(Icons.credit_card, color: Colors.grey),
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
            ),
            SizedBox(width: 16),
            // Refresh button
            ElevatedButton(
              onPressed: () {
                userPaymentStatus.clear();
                _setupRealTimePaymentMonitoring();
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

  // Build the table showing users and their payment status
  Widget _buildTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Senarai Ahli",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                var filteredUsers = getFilteredUsers();

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
                    final userId = user.userId.toString();

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
                        subtitle: Text(user.userIdentification),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getPaymentStatusWidget(userId),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () async {
                                try {
                                  // Set user first
                                  navController.setUser(user);

                                  // Convert userId to string and ensure it's not empty
                                  final userIdStr = user.userId.toString();
                                  if (userIdStr.isEmpty) {
                                    throw "ID pengguna tidak sah";
                                  }

                                  // Load required data (await both operations)
                                  await Future.wait([
                                    feeController.fetchYuranTertunggak(
                                      userIdStr,
                                    ),
                                    paymentController.fetchPaymentsByUserId(
                                      user.userId,
                                    ),
                                  ]);

                                  // Close loading dialog
                                  Get.back();

                                  // Navigate to yuran individu page
                                  navController.changeIndex(9);
                                } catch (e) {
                                  // Close loading dialog if there's an error
                                  Get.back();

                                  // Show error message
                                  Get.snackbar(
                                    'Ralat',
                                    'Gagal memuat data: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              },
                              tooltip: "Lihat Maklumat",
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.receipt_long,
                                color: Colors.amber,
                              ),
                              onPressed: () async {
                                try {
                                  
                                  // Set user first
                                  navController.setUser(user);

                                  // Convert userId to string and ensure it's not empty
                                  final userIdStr = user.userId.toString();
                                  if (userIdStr.isEmpty) {
                                    throw "ID pengguna tidak sah";
                                  }

                                  // Load required data (await both operations)
                                  await Future.wait([
                                    feeController.fetchYuranTertunggak(
                                      userIdStr,
                                    ),
                                    paymentController.fetchPaymentsByUserId(
                                      user.userId,
                                    ),
                                  ]);

                                  // Close loading dialog
                                  Get.back();

                                  // Navigate to yuran individu page
                                  navController.changeIndex(9);
                                } catch (e) {
                                  // Close loading dialog if there's an error
                                  Get.back();

                                  // Show error message
                                  Get.snackbar(
                                    'Ralat',
                                    'Gagal memuat data: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              },
                              tooltip: "Proses Pembayaran",
                            ),
                          ],
                        ),
                        onTap: () async {
                          try {
                            

                            // Set user first
                            navController.setUser(user);

                            // Convert userId to string and ensure it's not empty
                            final userIdStr = user.userId.toString();
                            if (userIdStr.isEmpty) {
                              throw "ID pengguna tidak sah";
                            }

                            // Load required data (await both operations)
                            await Future.wait([
                              feeController.fetchYuranTertunggak(userIdStr),
                              paymentController.fetchPaymentsByUserId(
                                user.userId,
                              ),
                            ]);

                            // Close loading dialog
                            Get.back();

                            // Navigate to yuran individu page
                            navController.changeIndex(9);
                          } catch (e) {
                            // Close loading dialog if there's an error
                            Get.back();

                            // Show error message
                            Get.snackbar(
                              'Ralat',
                              'Gagal memuat data: $e',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
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
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }
}
