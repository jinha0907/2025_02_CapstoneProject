// lib/widgets/weekly_study_chart.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 🔹 DTO import
import '../DTO/quiz_stats.dart'; // WeeklyQuizCount

class WeeklyStudyChart extends StatelessWidget {
  /// 서버에서 받은 7일치 퀴즈 통계
  final List<WeeklyQuizCount> weeklyData;

  const WeeklyStudyChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 maxY 계산: count 기준으로 상대 스케일 설정
    final double maxValue = weeklyData.isEmpty
        ? 0
        : weeklyData
        .map((e) => e.count.toDouble())
        .reduce(math.max);

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
          // bottomTitles 안 getTitlesWidget 수정
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyData.length) {
                  return const SizedBox.shrink();
                }

                final data = weeklyData[index];
                final String raw = data.date; // "2025-12-03"

                String label;
                if (raw.length >= 10) {
                  // yyyy-mm-dd → mm.dd
                  final month = raw.substring(5, 7); // "12"
                  final day = raw.substring(8, 10);  // "03"
                  label = "$month.$day";             // "12.03"
                } else {
                  label = raw;
                }

                return Text(
                  label,
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),

        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),

        // 🔹 터치 툴팁 ("요일\nn문제") — 이 부분은 그대로 두었음
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // fl_chart 0.68.0: tooltipBgColor 대신 getTooltipColor 사용
            getTooltipColor: (group) => const Color(0xFF4E7C88),
            tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              if (index < 0 || index >= weeklyData.length) return null;

              final data = weeklyData[index];

              DateTime? dateTime;
              try {
                dateTime = DateTime.parse(data.date);
              } catch (_) {}

              // 요일 텍스트 매핑용
              const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

              String dayLabel = '';
              if (dateTime != null) {
                final weekdayIndex = dateTime.weekday - 1;
                if (weekdayIndex >= 0 && weekdayIndex < weekdayLabels.length) {
                  dayLabel = weekdayLabels[weekdayIndex];
                }
              }

              final count = data.count;

              return BarTooltipItem(
                '$dayLabel\n${count}문제',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),

        // 🔹 각 날짜별 막대 생성
        barGroups: List.generate(
          weeklyData.length,
              (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weeklyData[i].count.toDouble(),
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
