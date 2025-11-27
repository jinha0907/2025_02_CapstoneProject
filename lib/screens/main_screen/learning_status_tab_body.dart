import 'package:flutter/material.dart';
import 'package:korean_culture_quiz/widgets/weekly_study_chart.dart';

class LearningStatusTabBody extends StatelessWidget {
  final List<double> weeklyData;
  final String tierName;
  final int totalQuizCount;
  final double completionRatio; // 0.0 ~ 1.0

  const LearningStatusTabBody({
    super.key,
    required this.weeklyData,
    this.tierName = '새싹',
    this.totalQuizCount = 30,
    this.completionRatio = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8E3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 타이틀 =====
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '학습 현황',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== 상단: 캐릭터 + 티어 카드 =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 110,
                    height: 160,
                    child: Image.asset(
                      'assets/images/tiger_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '내 티어: $tierName',
                              style: const TextStyle(
                                color: Color(0xFF2C2C2C),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('🌱', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '퀴즈를 풀어 단계를 올려보세요!',
                          style: TextStyle(
                            color: Color(0xFF858494),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== 프로그레스 바 (호랑이 아래로 이동) =====
            _ProgressBar(completionRatio: completionRatio),

            const SizedBox(height: 10),

            // ===== 전체 푼 퀴즈 개수 =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F6),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                '전체 푼 퀴즈 개수 : $totalQuizCount',
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== 주간 학습량 그래프 =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F6),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주간 학습량',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: WeeklyStudyChart(weeklyData: weeklyData),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double completionRatio;

  const _ProgressBar({required this.completionRatio});

  @override
  Widget build(BuildContext context) {
    final ratio = completionRatio.clamp(0.0, 1.0);

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * ratio;
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF4E7C88),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}
