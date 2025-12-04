// lib/widgets/weekly_study_chart.dart
import 'dart:math' as math;
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

    // 🔹 데이터 최대값 기준으로 maxY 자동 설정 (상대적 스케일)
    final double maxValue =
    weeklyData.isEmpty ? 0 : weeklyData.reduce(math.max);
    final double maxY =
    (maxValue <= 0) ? 1.0 : (maxValue * 1.2).ceilToDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  days[index],
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),

        // 🔹 터치 툴팁 설정 (배경색 + "n문제")
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // fl_chart 0.68.0에서는 tooltipBgColor 대신 getTooltipColor 사용
            getTooltipColor: (group) => const Color(0xFF4E7C88),
            tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayIndex = group.x.toInt();
              final dayLabel = (dayIndex >= 0 && dayIndex < days.length)
                  ? days[dayIndex]
                  : '';

              final count = rod.toY.toInt(); // 6.0 → 6

              return BarTooltipItem(
                '$dayLabel\n$count문제', // ← "#$count문제"로 바꾸고 싶으면 여기만 수정
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),

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
