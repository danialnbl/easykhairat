import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RegisteredMembersChart extends StatelessWidget {
  const RegisteredMembersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pendaftaran Baru Mengikut Tahun', // Registered Members by Year
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
                        (_) =>
                            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    getDrawingVerticalLine:
                        (_) =>
                            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(show: true),
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
