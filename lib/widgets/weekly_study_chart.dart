// lib/widgets/weekly_study_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyStudyChart extends StatelessWidget {
  final List<double> weeklyData;

  const WeeklyStudyChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 6,
        minY: 0,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                days[value.toInt()],
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          weeklyData.length,
              (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weeklyData[i],
                width: 18,
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF4E7C88),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
