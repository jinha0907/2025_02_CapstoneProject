// lib/screens/tabs/learning_status_tab_body.dart
import 'package:flutter/material.dart';
import 'package:korean_culture_quiz/widgets/weekly_study_chart.dart';

import '../../info/user_info.dart'; // 🔥 UserInfo에서 totalExp, tier 읽기

class LearningStatusTabBody extends StatelessWidget {
  final List<double> weeklyData;
  final String tierName;
  final int totalQuizCount;
  final double completionRatio; // 기존 필드(호환용, 없애도 되지만 일단 유지)

  const LearningStatusTabBody({
    super.key,
    required this.weeklyData,
    this.tierName = '새싹',
    this.totalQuizCount = 0,
    this.completionRatio = 0.0,
  });

  /// 🔥 실제 로그인 유저의 totalExp + tier 를 기준으로
  /// 0.0 ~ 1.0 사이의 진행도를 계산
  double _calcExpRatio() {
    final user = UserInfo.currentUser;

    // 로그인 안 돼 있으면, 기존에 주던 값 사용 (혹은 0.0)
    if (user == null) {
      return completionRatio.clamp(0.0, 1.0);
    }

    final int exp = user.totalExp;
    final String tier = user.tier; // ex: '브론즈', '실버', '골드', '플래티넘'

    // 플래티넘은 항상 꽉 찬 상태
    if (tier.contains('플래티넘')) {
      return 1.0;
    }

    // 혹시 영어로 들어올 수도 있을 상황까지 대비 (선택사항)
    final lower = tier.toLowerCase();

    // 브론즈 0~999 → 통 크기 1000
    if (tier.contains('브론즈') || lower.contains('bronze')) {
      final local = exp.clamp(0, 999);
      return local / 1000.0;
    }

    // 실버 1000~4999 → 통 크기 4000
    if (tier.contains('실버') || lower.contains('silver')) {
      final local = (exp - 1000).clamp(0, 3999); // 0 ~ 3999
      return local / 4000.0;
    }

    // 골드 5000~9999 → 통 크기 5000
    if (tier.contains('골드') || lower.contains('gold')) {
      final local = (exp - 5000).clamp(0, 4999); // 0 ~ 4999
      return local / 5000.0;
    }

    // 만약 tier 문자열이 예외적인 값이면:
    // 1만 기준으로 대충 비율 계산 (혹은 0.0으로 둬도 됨)
    return (exp.clamp(0, 10000) / 10000.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 여기서 현재 유저 기준으로 진행도 계산
    final expRatio = _calcExpRatio();

    return Container(
      color: const Color(0xFFEDE8E3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // ===== 상단: 호랑이 + 설명 카드 =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Image.asset(
                    'assets/images/tiger_image.png',
                    width: 100,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          '학습 현황',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '이번 주 학습 진행 상황이에요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== 티어 정보 박스 (프로그레스 바 위) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내 티어: $tierName',
                          style: const TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '퀴즈를 풀어 티어를 올려보세요!',
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🌱', style: TextStyle(fontSize: 26)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== 프로그레스 바 (경험치 기반) =====
            _ProgressBar(completionRatio: expRatio),

            const SizedBox(height: 10),

            // ===== 전체 푼 퀴즈 개수 =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F6),
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
