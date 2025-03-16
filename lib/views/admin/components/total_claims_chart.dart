import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TotalClaimsChart extends StatefulWidget {
  const TotalClaimsChart({super.key});

  @override
  State<TotalClaimsChart> createState() => _TotalClaimsChartState();
}

class _TotalClaimsChartState extends State<TotalClaimsChart> {
  List<Color> gradientColors = [Colors.redAccent, Colors.deepOrange];

  bool showAvg = false;

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
              'Tuntutan Ahli Keseluruhan Mengikut Tahun', // Total Claims Over the Years
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(showAvg ? avgData() : mainData()),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'Avg',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        showAvg ? Colors.black.withOpacity(0.5) : Colors.black,
                  ),
                ),
              ),
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
      case 0:
        text = const Text('2019', style: style);
        break;
      case 1:
        text = const Text('2020', style: style);
        break;
      case 2:
        text = const Text('2021', style: style);
        break;
      case 3:
        text = const Text('2022', style: style);
        break;
      case 4:
        text = const Text('2023', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta, // ✅ Pass meta correctly
      child: text,
      space: 8,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10K';
        break;
      case 20:
        text = '20K';
        break;
      case 30:
        text = '30K';
        break;
      case 40:
        text = '40K';
        break;
      case 50:
        text = '50K';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
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
            reservedSize: 42,
            interval: 10,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 50,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 12), // 2019
            FlSpot(1, 18), // 2020
            FlSpot(2, 30), // 2021
            FlSpot(3, 25), // 2022
            FlSpot(4, 40), // 2023
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
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 25),
            FlSpot(1, 25),
            FlSpot(2, 25),
            FlSpot(3, 25),
            FlSpot(4, 25),
          ],
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
