import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final int value;
  final double percentage;
  final double change;
  final Color color;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.change,
    this.color = Colors.purple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side (Text)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.purple, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "+$change% Inc",
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right Side (Progress Chart)
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: color,
                        value: percentage,
                        radius: 6,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.grey[300],
                        value: 100 - percentage,
                        radius: 6,
                        showTitle: false,
                      ),
                    ],
                    centerSpaceRadius: 14,
                    sectionsSpace: 0,
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Center(
                  child: Text(
                    "+${percentage.toInt()}%",
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
