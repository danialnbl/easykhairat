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

  Map<int, double> getYearlyClaimAmounts() {
    Map<int, double> yearlyAmounts = {};

    for (var claimLine in claimLineController.claimLineList) {
      // Get year from the created_at date
      DateTime createdAt = claimLine.claimLineCreatedAt ?? DateTime.now();
      int year = createdAt.year;

      // Use the total price from the claim line
      double amount = claimLine.claimLineTotalPrice?.toDouble() ?? 0;
      yearlyAmounts[year] = (yearlyAmounts[year] ?? 0) + amount;
    }

    return yearlyAmounts;
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
              'Jumlah Tuntutan (RM) Mengikut Tahun',
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

    int valueAsInt = value.toInt();
    text = Text(valueAsInt.toString(), style: style);

    return SideTitleWidget(meta: meta, child: text, space: 8);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    return Text('RM ${value.toInt()}', style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    final yearlyData = getYearlyClaimAmounts();

    // Get current year
    int currentYear = DateTime.now().year;

    // Create a fixed range of years: current year and 3 years before
    List<int> years = [
      currentYear - 3,
      currentYear - 2,
      currentYear - 1,
      currentYear,
    ];

    double maxAmount =
        yearlyData.isEmpty
            ? 500
            : (yearlyData.values.reduce((a, b) => a > b ? a : b) * 1.2).clamp(
              500,
              double.infinity,
            );

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxAmount > 1000 ? 200 : 100,
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
            interval: maxAmount > 1000 ? 200 : 100,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      minX: currentYear - 3, // Starting year (current year - 3)
      maxX: currentYear.toDouble(), // Ending year (current year)
      minY: 0,
      maxY: maxAmount,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int year in years)
              FlSpot(year.toDouble(), yearlyData[year] ?? 0),
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
    final yearlyData = getYearlyClaimAmounts();

    // Get current year
    int currentYear = DateTime.now().year;

    // Create a fixed range of years: current year and 3 years before
    List<int> years = [
      currentYear - 3,
      currentYear - 2,
      currentYear - 1,
      currentYear,
    ];

    double average =
        yearlyData.isEmpty
            ? 0
            : yearlyData.values.reduce((a, b) => a + b) / yearlyData.length;

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
      minX: currentYear - 3, // Starting year (current year - 3)
      maxX: currentYear.toDouble(), // Ending year (current year)
      minY: 0,
      maxY: average * 2,
      lineBarsData: [
        LineChartBarData(
          spots: years.map((year) => FlSpot(year.toDouble(), average)).toList(),
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
