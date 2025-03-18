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
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const yearMap = {
                            0: '2019',
                            1: '2020',
                            2: '2021',
                            3: '2022',
                            4: '2023',
                            5: '2024',
                            6: '2025',
                          };
                          return Text(
                            yearMap[value.toInt()] ?? '',
                            style: const TextStyle(fontSize: 12),
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
                      spots: const [
                        FlSpot(0, 5), // 2019
                        FlSpot(1, 10), // 2020
                        FlSpot(2, 15), // 2021
                        FlSpot(3, 12), // 2022
                        FlSpot(4, 9), // 2023
                        FlSpot(5, 14), // 2024
                        FlSpot(6, 18), // 2025
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
