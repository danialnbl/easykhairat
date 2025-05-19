import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';

class TotalClaimsChart extends StatefulWidget {
  const TotalClaimsChart({super.key});

  @override
  State<TotalClaimsChart> createState() => _TotalClaimsChartState();
}

class _TotalClaimsChartState extends State<TotalClaimsChart> {
  final TuntutanController tuntutanController = Get.find<TuntutanController>();
  List<Color> gradientColors = [Colors.redAccent, Colors.deepOrange];
  bool showAvg = false;

  Map<int, int> getMonthlyClaimCounts() {
    Map<int, int> monthlyTotals = {};

    for (var claim in tuntutanController.tuntutanList) {
      int month = claim.claimCreatedAt.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + 1;
    }

    return monthlyTotals;
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
              'Tuntutan Ahli Keseluruhan Mengikut Bulan',
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
                return LineChart(showAvg ? avgData() : mainData());
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Jan', style: style);
        break;
      case 3:
        text = const Text('Mar', style: style);
        break;
      case 6:
        text = const Text('Jun', style: style);
        break;
      case 9:
        text = const Text('Sep', style: style);
        break;
      case 12:
        text = const Text('Dis', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(meta: meta, child: text, space: 8);
  }

  LineChartData mainData() {
    final monthlyData = getMonthlyClaimCounts();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      minX: 1,
      maxX: 12,
      minY: 0,
      maxY:
          monthlyData.isEmpty
              ? 10
              : (monthlyData.values.reduce((a, b) => a > b ? a : b) + 2)
                  .toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int month = 1; month <= 12; month++)
              FlSpot(month.toDouble(), monthlyData[month]?.toDouble() ?? 0),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    final monthlyData = getMonthlyClaimCounts();
    double average =
        monthlyData.isEmpty
            ? 0
            : monthlyData.values.reduce((a, b) => a + b) / monthlyData.length;

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(12, (i) => FlSpot(i + 1, average)),
          isCurved: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.5)).toList(),
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors
                      .map((color) => color.withOpacity(0.1))
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
