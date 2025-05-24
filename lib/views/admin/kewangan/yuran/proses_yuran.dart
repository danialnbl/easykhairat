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
                  // Status Bayaran - Updated to use payment status
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(child: _getPaymentStatusWidget(user.userId)),
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
                const SizedBox(width: 16),
                _buildRefreshButton(),
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
