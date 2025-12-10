// lib/screens/tabs/learning_status_tab_body.dart
import 'package:flutter/material.dart';
import 'package:korean_culture_quiz/widgets/weekly_study_chart.dart';
import 'package:korean_culture_quiz/DTO/quiz_stats.dart';

import '../../info/user_info.dart'; // 🔥 UserInfo에서 totalExp, tier 읽기

/// 티어 진행도 정보 묶음
class _ExpProgress {
  final double ratio;          // 0.0 ~ 1.0
  final int currentLocalExp;   // 현재까지 누적 경험치 (표시용)
  final int tierMaxExp;        // 누적 기준 전체 통 크기 (예: 1000, 5000, 9000)

  const _ExpProgress({
    required this.ratio,
    required this.currentLocalExp,
    required this.tierMaxExp,
  });

  int get remainingExp => (tierMaxExp - currentLocalExp).clamp(0, tierMaxExp);
}

class LearningStatusTabBody extends StatelessWidget {
  final List<WeeklyQuizCount> weeklyData;
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
  /// ratio + (현재 EXP / 누적 통 크기) 를 모두 계산해서 반환
  ///
  /// 브론즈: cap = 1000
  /// 실버  : cap = 5000
  /// 골드  : cap = 9000
  /// 플래티넘: exp 기준으로 1.0, 표시는 exp 단독
  _ExpProgress _calcExpProgress() {
    final user = UserInfo.currentUser;

    // 로그인 안 돼 있으면, 기존 completionRatio 만 사용
    if (user == null) {
      final r = completionRatio.clamp(0.0, 1.0);
      return _ExpProgress(ratio: r, currentLocalExp: 0, tierMaxExp: 0);
    }

    final int exp = user.totalExp;
    final String tierRaw = user.tier;
    final String tier = tierRaw.toLowerCase();

    // 브론즈: 0~999 → cap = 1000
    if (tier.contains('브론즈') || tier.contains('bronze')) {
      const cap = 1000;
      final r = (exp / cap).clamp(0.0, 1.0);
      return _ExpProgress(
        ratio: r,
        currentLocalExp: exp.clamp(0, cap),
        tierMaxExp: cap,
      );
    }

    // 실버: 1000~4999 → cap = 5000
    if (tier.contains('실버') || tier.contains('silver')) {
      const cap = 5000;
      final r = (exp / cap).clamp(0.0, 1.0);
      return _ExpProgress(
        ratio: r,
        currentLocalExp: exp.clamp(0, cap),
        tierMaxExp: cap,
      );
    }

    // 골드: 5000~8999 → cap = 9000
    if (tier.contains('골드') || tier.contains('gold')) {
      const cap = 9000;
      final r = (exp / cap).clamp(0.0, 1.0);
      return _ExpProgress(
        ratio: r,
        currentLocalExp: exp.clamp(0, cap),
        tierMaxExp: cap,
      );
    }

    // 플래티넘 이상 → 게이지는 항상 1.0, 표시는 exp 단독
    if (tier.contains('플래티넘') || tier.contains('platinum')) {
      return _ExpProgress(
        ratio: 1.0,
        currentLocalExp: exp,
        tierMaxExp: exp,
      );
    }

    // 예외적 티어 → 그냥 전체 기준 10,000 cap
    const cap = 10000;
    final r = (exp / cap).clamp(0.0, 1.0);
    return _ExpProgress(
      ratio: r,
      currentLocalExp: exp.clamp(0, cap),
      tierMaxExp: cap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 여기서 현재 유저 기준으로 진행도 + 누적 통 크기 계산
    final expProgress = _calcExpProgress();
    final expRatio = expProgress.ratio;

    final String userTier = UserInfo.currentUser?.tier ?? tierName;
    final String userTierLower = userTier.toLowerCase();
    final bool isPlatinum =
        userTier.contains('플래티넘') || userTierLower.contains('platinum');

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
                  // 왼쪽: 텍스트
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
                  // 오른쪽: 티어 PNG + (플래티넘이면 금색 테두리)
                  _TierIcon(tierName: tierName),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== 프로그레스 바 (경험치 기반) =====
            // 플래티넘이면 숨기기
            if (!isPlatinum) _ProgressBar(completionRatio: expRatio),

            if (!isPlatinum) const SizedBox(height: 6),

            // ===== 프로그레스 바 하단: 현재 티어 경험치 정보 =====
            if (expProgress.tierMaxExp > 0)
              Align(
                alignment: Alignment.center,
                child: () {
                  // 플래티넘이면 "현재 EXP만" 표시
                  if (isPlatinum) {
                    return Text(
                      '${expProgress.currentLocalExp} EXP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    );
                  }

                  // 나머지 티어는 누적 통 기준 / 남은 EXP 표시
                  return Text(
                        '${expProgress.currentLocalExp} / ${expProgress.tierMaxExp} EXP'
                        ' · 다음 티어까지 ${expProgress.remainingExp} EXP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                    ),
                  );
                }(),
              ),

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

/// 🔥 티어 PNG 아이콘 전용 위젯
/// 플래티넘이면 금색 테두리 적용
class _TierIcon extends StatelessWidget {
  final String tierName;

  const _TierIcon({required this.tierName});

  String _assetPathForTier(String tier) {
    final lower = tier.toLowerCase();

    if (tier.contains('브론즈') || lower.contains('bronze')) {
      return 'assets/images/bronze.png';
    }
    if (tier.contains('실버') || lower.contains('silver')) {
      return 'assets/images/silver.png';
    }
    if (tier.contains('골드') || lower.contains('gold')) {
      return 'assets/images/gold.png';
    }
    if (tier.contains('플래티넘') || lower.contains('platinum')) {
      return 'assets/images/platinum.png';
    }

    // 🔥 디폴트 = 브론즈
    return 'assets/images/bronze.png';
  }


  @override
  Widget build(BuildContext context) {
    // 로그인 유저 티어가 있으면 그걸 우선, 없으면 파라미터 tierName 사용
    final String userTier = UserInfo.currentUser?.tier ?? tierName;
    final String lower = userTier.toLowerCase();
    final bool isPlatinum =
        userTier.contains('플래티넘') || lower.contains('platinum');

    final assetPath = _assetPathForTier(userTier);

    final image = Image.asset(
      assetPath,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
    );

    if (!isPlatinum) {
      return image;
    }

    // 플래티넘: 금색 테두리
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFD700), // 골드색
          width: 2,
        ),
      ),
      child: ClipOval(child: image),
    );
  }
}
