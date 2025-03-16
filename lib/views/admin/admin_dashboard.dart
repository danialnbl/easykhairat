import 'package:easykhairat/views/admin/components/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:easykhairat/views/admin/components/overall_fee_chart.dart';
import 'package:easykhairat/views/admin/components/registered_members_chart.dart';
import 'package:easykhairat/views/admin/components/total_claims_chart.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
              child: _statCard(
                'Jumlah Ahli Aktif',
                '49',
                '+5.25%',
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                'Kutipan Yuran Tahun Ini',
                'RM45,320',
                '-1.23%',
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                'Tuntutan Ahli Tahun Ini',
                'RM50,320',
                '-1.23%',
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statCard('Jumlah Admin', '2', '+5.25%', Colors.green),
            ),
            Expanded(
              child: _statCard('Jumlah AJK', '10', '+5.25%', Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(flex: 1, child: RegisteredMembersChart()),
            const SizedBox(width: 8),
            const Expanded(flex: 1, child: OverallFeeChart()),
            const SizedBox(width: 8),
            const Expanded(flex: 1, child: TotalClaimsChart()),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, String change, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  change.startsWith('-')
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: color,
                  size: 14,
                ),
                Text(change, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
