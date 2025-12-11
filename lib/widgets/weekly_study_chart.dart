// lib/widgets/weekly_study_chart.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 🔹 DTO import
import '../DTO/quiz_stats.dart'; // WeeklyQuizCount
import '../DTO/quiz_accuracy_trend.dart'; // AccuracyTrendPoint

class WeeklyStudyChart extends StatelessWidget {
  /// 서버에서 받은 7일치 퀴즈 통계 (막대그래프 Y값)
  /// date: "yyyy-MM-dd" 형식의 문자열이라고 가정
  final List<WeeklyQuizCount> weeklyData;

  /// 🔥 정답률 추이 (날짜별 맞춘/틀린/정답률)
  /// AccuracyTrendPoint.date: DateTime
  /// → toIso8601String().split('T').first 로 "yyyy-MM-dd" 키를 만들어
  /// weeklyData.date 와 매칭해서 막대 위 텍스트로 사용
  final List<AccuracyTrendPoint>? trendData;

  const WeeklyStudyChart({
    super.key,
    required this.weeklyData,
    this.trendData,
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

    // 🔥 trendData 를 "yyyy-MM-dd" 문자열 기준으로 매핑
    final Map<String, AccuracyTrendPoint> trendMap = {};
    if (trendData != null) {
      for (final p in trendData!) {
        final key = p.date.toIso8601String().split('T').first; // "yyyy-MM-dd"
        trendMap[key] = p;
      }
    }

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

          // 🔥 막대 위 (맞춘/전체) 정답률%
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: trendData != null, // 메인 화면에서는 null → 안 보임
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                if (trendData == null) {
                  return const SizedBox.shrink();
                }

                final index = value.toInt();
                if (index < 0 || index >= weeklyData.length) {
                  return const SizedBox.shrink();
                }

                final data = weeklyData[index];
                final raw = data.date; // "2025-12-03" 같은 String
                final key =
                raw.length >= 10 ? raw.substring(0, 10) : raw; // yyyy-MM-dd

                final point = trendMap[key];
                if (point == null || point.total <= 0) {
                  return const SizedBox.shrink();
                }

                final correct = point.correct;
                final total = point.total;
                final percent =
                (point.accuracy * 100).toStringAsFixed(0); // 0~100

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 여기: (맞춘/전체)
                      Text(
                        '($correct/$total)',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF555555),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔹 x축: "mm.dd" 형식 (기존 그대로 유지)
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
                  final day = raw.substring(8, 10); // "03"
                  label = "$month.$day"; // "12.03"
                } else {
                  label = raw;
                }

                return Text(
                  label,
                  style: const TextStyle(fontSize: 11),
                );
              },
              reservedSize: 24,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),

        // 🔹 터치 툴팁 ("요일\nn문제") — 네가 쓰던 버전 그대로 유지
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

        // 🔹 각 날짜별 막대 생성 (기존 그대로)
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
