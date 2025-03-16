import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moon_design/moon_design.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard Overview',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 0, end: 5),
          badgeContent: const Text('3', style: TextStyle(color: Colors.white)),
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ],
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
        Row(children: [Expanded(flex: 2, child: _buildRevenueChart())]),
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
            Text(
              title,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.arrow_upward, color: color, size: 14),
                Text(change, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendaftaran Baru Mengikut Tahun',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      spots: const [
                        FlSpot(0, 5),
                        FlSpot(1, 10),
                        FlSpot(2, 15),
                        FlSpot(3, 12),
                        FlSpot(4, 9),
                        FlSpot(5, 14),
                        FlSpot(6, 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
