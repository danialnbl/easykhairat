import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/payment_controller.dart';

class OverallFeeChart extends StatelessWidget {
  OverallFeeChart({super.key});

  final PaymentController paymentController = Get.find<PaymentController>();

  List<MapEntry<int, double>> getYearlyTotals() {
    // Create a map to store yearly totals
    Map<int, double> yearlyTotals = {};

    // Group payments by year and sum their values
    for (var payment in paymentController.payments) {
      int year = payment.paymentCreatedAt.year;
      yearlyTotals[year] = (yearlyTotals[year] ?? 0) + payment.paymentValue;
    }

    // Convert to list and sort by year
    var sortedEntries =
        yearlyTotals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

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
              'Kutipan Yuran Tahunan',
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
                final yearlyData = getYearlyTotals();
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
                            final index = value.toInt();
                            if (index >= 0 && index < yearlyData.length) {
                              return Text(
                                yearlyData[index].key.toString(),
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
                      yearlyData.length,
                      (index) => _barChartGroup(
                        index,
                        yearlyData[index].value,
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
