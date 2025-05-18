import 'package:easykhairat/controllers/claimline_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/widgets/admin/overall_fee_chart.dart';
import 'package:easykhairat/widgets/admin/registered_members_chart.dart';
import 'package:easykhairat/widgets/admin/total_claims_chart.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserController userController = Get.put(UserController());
  final PaymentController paymentController = Get.put(PaymentController());
  final TuntutanController tuntutanController = Get.put(TuntutanController());
  final ClaimLineController claimLineController = Get.put(
    ClaimLineController(),
  );

  @override
  void initState() {
    super.initState();
    if (userController.users.isEmpty && !userController.isLoading.value) {
      userController.fetchUsers();
      userController.fetchAdmin();
    }
    paymentController.fetchTotalPayments();
    userController.fetchAdminDetailsByIdAndAssign(
      Supabase.instance.client.auth.currentUser?.id ?? "",
    );
    claimLineController.fetchTotalClaimLine();

    print("Admin ID: ${Supabase.instance.client.auth.currentUser?.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: "Dashboard Overview",
                notificationCount: 3,
                onNotificationPressed: () {},
              ),
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
                          label: Text(
                            "Home",
                            style: const TextStyle(color: Colors.black),
                          ),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(
                          label: Text(
                            "Dashboard",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => _statCard(
                  'Jumlah Ahli Aktif',
                  userController.users.length.toString(), // dynamic count

                  Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(
                () => _statCard(
                  'Kutipan Yuran',
                  'RM ${paymentController.totalPayments.value.toStringAsFixed(2)}',

                  Colors.red,
                ),
              ),
            ),

            const SizedBox(width: 8),
            Expanded(
              child: Obx(
                () => _statCard(
                  'Tuntutan Ahli Tahun Ini',
                  'RM ${claimLineController.totalClaimLine.value.toStringAsFixed(2)}',

                  Colors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _statCard(
                  'Jumlah Admin',
                  userController.adminUsers.length.toString(),

                  Colors.green,
                ),
              ),
            ),

            Expanded(child: _statCard('Jumlah AJK', '10', Colors.green)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 1, child: RegisteredMembersChart()),
            const SizedBox(width: 8),
            const Expanded(flex: 1, child: OverallFeeChart()),
            const SizedBox(width: 8),
            const Expanded(flex: 1, child: TotalClaimsChart()),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
