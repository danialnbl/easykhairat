import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/payment_controller.dart';

class OverallFeeChart extends StatelessWidget {
  OverallFeeChart({super.key});

  final PaymentController paymentController = Get.find<PaymentController>();

  List<MapEntry<int, double>> getMonthlyTotals() {
    // Create a map to store monthly totals
    Map<int, double> monthlyTotals = {};

    // Group payments by month and sum their values
    for (var payment in paymentController.payments) {
      int month = payment.paymentCreatedAt.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + payment.paymentValue;
    }

    // Convert to list and sort by month
    var sortedEntries =
        monthlyTotals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries;
  }

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
              'Kutipan Yuran Keseluruhan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Obx(() {
                final monthlyData = getMonthlyTotals();
                return BarChart(
                  BarChartData(
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
                          reservedSize: 60,
                          getTitlesWidget:
                              (value, _) => Text(
                                'RM ${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            final index = value.toInt();
                            if (index >= 0 && index < monthlyData.length) {
                              return Text(
                                months[monthlyData[index].key - 1],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      monthlyData.length,
                      (index) => _barChartGroup(
                        index,
                        monthlyData[index].value,
                        Colors.blue,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barChartGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
