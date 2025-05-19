import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';

class RegisteredMembersChart extends StatelessWidget {
  RegisteredMembersChart({super.key});

  final UserController userController = Get.find<UserController>();

  List<FlSpot> _getSpots() {
    final registrations = userController.getRegistrationsByYear();
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 3; // Show last 4 years

    List<FlSpot> spots = [];
    for (int i = 0; i < 4; i++) {
      // Changed from 7 to 4
      int year = startYear + i;
      double count = registrations[year]?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), count));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final spots = _getSpots();
      final currentYear = DateTime.now().year;
      final startYear = currentYear - 3; // Changed from 6 to 3

      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Added padding to match overall_fee_chart
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                // Removed Padding widget since we have parent padding
                'Pendaftaran Baru Mengikut Tahun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine:
                          (_) => FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          ),
                      getDrawingVerticalLine:
                          (_) => FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          ),
                    ),
                    minX: 0,
                    maxX: 3,
                    minY: 0,
                    maxY: spots
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) return const Text('');
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // Forces whole number intervals
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final year = (startYear + value.toInt()).toString();
                            return SideTitleWidget(
                              meta: meta,
                              angle: 0,
                              child: Text(
                                year,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        spots: spots,
                        preventCurveOverShooting: true,
                        isStrokeCapRound: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
