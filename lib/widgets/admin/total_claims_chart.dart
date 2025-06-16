import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/tuntutan_controller.dart';
import 'package:easykhairat/controllers/claimline_controller.dart';

class TotalClaimsChart extends StatefulWidget {
  const TotalClaimsChart({super.key});

  @override
  State<TotalClaimsChart> createState() => _TotalClaimsChartState();
}

class _TotalClaimsChartState extends State<TotalClaimsChart> {
  final TuntutanController tuntutanController = Get.find<TuntutanController>();
  final ClaimLineController claimLineController =
      Get.find<ClaimLineController>();
  List<Color> gradientColors = [Colors.redAccent, Colors.deepOrange];
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await claimLineController.fetchClaimLines();
  }

  Map<int, double> getMonthlyClaimAmounts() {
    Map<int, double> monthlyAmounts = {};

    for (var claimLine in claimLineController.claimLineList) {
      // Get month from the created_at date
      DateTime createdAt = claimLine.claimLineCreatedAt ?? DateTime.now();
      int month = createdAt.month;

      // Use the total price from the claim line
      double amount = claimLine.claimLineTotalPrice?.toDouble() ?? 0;
      monthlyAmounts[month] = (monthlyAmounts[month] ?? 0) + amount;
    }

    return monthlyAmounts;
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
              'Jumlah Tuntutan (RM) Mengikut Bulan',
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
                return claimLineController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : LineChart(showAvg ? avgData() : mainData());
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

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    return Text('RM ${value.toInt()}', style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    final monthlyData = getMonthlyClaimAmounts();

    double maxAmount =
        monthlyData.isEmpty
            ? 1000
            : (monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxAmount > 5000 ? 1000 : 500,
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
            reservedSize: 54,
            interval: maxAmount > 5000 ? 1000 : 500,
            getTitlesWidget: leftTitleWidgets,
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
      maxY: maxAmount,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int month = 1; month <= 12; month++)
              FlSpot(month.toDouble(), monthlyData[month] ?? 0),
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
    final monthlyData = getMonthlyClaimAmounts();
    double average =
        monthlyData.isEmpty
            ? 0
            : monthlyData.values.reduce((a, b) => a + b) / monthlyData.length;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 500,
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
            reservedSize: 54,
            interval: 500,
            getTitlesWidget: leftTitleWidgets,
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
      maxY: average * 2,
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
