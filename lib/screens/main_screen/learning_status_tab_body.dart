// lib/screens/tabs/learning_status_tab_body.dart

import 'package:flutter/material.dart';

import '../../widgets/weekly_study_chart.dart';
import '../../DTO/quiz_stats.dart';

import '../../DTO/user_quiz_accuracy.dart';
import '../../DTO/quiz_category_stats.dart';
import '../../DTO/quiz_category_performance.dart';
import '../../DTO/quiz_accuracy_trend.dart';

import '../../api/learning_status_api.dart';
import '../../info/user_info.dart';

/// 티어 진행도 정보 묶음
class _ExpProgress {
  final double ratio; // 0.0 ~ 1.0
  final int currentLocalExp; // 현재까지 누적 경험치 (표시용)
  final int tierMaxExp; // 누적 기준 전체 통 크기 (예: 1000, 5000, 9000)

  const _ExpProgress({
    required this.ratio,
    required this.currentLocalExp,
    required this.tierMaxExp,
  });

  int get remainingExp => (tierMaxExp - currentLocalExp).clamp(0, tierMaxExp);
}

/// 학습현황 탭 화면
class LearningStatusTabBody extends StatefulWidget {
  /// 주간 학습량 그래프용 데이터 (MainTabScaffold 에서 전달)
  final List<WeeklyQuizCount> weeklyData;

  const LearningStatusTabBody({
    super.key,
    required this.weeklyData,
  });

  @override
  State<LearningStatusTabBody> createState() => _LearningStatusTabBodyState();
}

class _LearningStatusTabBodyState extends State<LearningStatusTabBody> {
  bool _loading = false;
  String? _errorMessage;

  UserQuizAccuracy? _accuracy;
  List<CategorySolvedCount> _categorySolved = const [];
  UserCategoryPerformanceStats? _categoryPerformance;
  UserAccuracyTrend? _accuracyTrend;

  @override
  void initState() {
    super.initState();
    _loadLearningStatus();
  }

  Future<void> _loadLearningStatus() async {
    final user = UserInfo.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = '로그인 정보가 없어 학습현황을 불러올 수 없습니다.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final bundle =
      await LearningStatusApi.instance.fetchLearningStatusBundle(user.userId);

      setState(() {
        _accuracy = bundle.accuracy;
        _categorySolved = bundle.categorySolved;
        _categoryPerformance = bundle.categoryPerformance;
        _accuracyTrend = bundle.accuracyTrend;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '학습현황을 불러오는 중 오류가 발생했습니다.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// 🔥 실제 로그인 유저의 totalExp + tier 를 기준으로
  /// ratio + (현재 EXP / 누적 통 크기) 를 모두 계산해서 반환
  ///
  /// 브론즈: cap = 1000
  /// 실버  : cap = 5000
  /// 골드  : cap = 9000
  /// 플래티넘: exp 기준으로 1.0, 표시는 exp 단독
  _ExpProgress _calcExpProgress() {
    final user = UserInfo.currentUser;

    // 로그인 안 돼 있으면, 진행도 0
    if (user == null) {
      return const _ExpProgress(ratio: 0.0, currentLocalExp: 0, tierMaxExp: 0);
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
    final user = UserInfo.currentUser;
    final String userTier = user?.tier ?? '새싹';
    final String userTierLower = userTier.toLowerCase();
    final bool isPlatinum =
        userTier.contains('플래티넘') || userTierLower.contains('platinum');

    final expProgress = _calcExpProgress();
    final double expRatio = expProgress.ratio;

    // 정답률 표시용
    final acc = _accuracy;
    final int totalQuizCount = acc?.totalQuizzes ?? 0;
    final int correctQuizCount = acc?.correctQuizzes ?? 0;
    final double accuracyPercent = acc?.accuracyPercent ?? 0.0;

    // 많이 맞힌/틀린 카테고리 리스트
    final mostCorrectCategories =
        _categoryPerformance?.mostCorrect ?? const <CategoryPerformanceItem>[];
    final mostWrongCategories =
        _categoryPerformance?.mostWrong ?? const <CategoryPerformanceItem>[];

    // ===== 로딩 화면 =====
    if (_loading) {
      return Container(
        color: const Color(0xFFEDE8E3),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      color: const Color(0xFFEDE8E3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // 에러 표시
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFB00020),
                    fontSize: 12,
                  ),
                ),
              ),

            // ===== 상단: 호랑이 + 설명 카드 (흰색 카드) =====
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
                      color: Colors.white,              // 🔥 카드 색 통일
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                          '내 학습량과 정답률, 카테고리별 성과를\n한눈에 확인해보세요.',
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

            // ===== 티어 정보 박스 (흰색 카드) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,                    // 🔥 카드 색 통일
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
                          '내 티어: $userTier',
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
                  _TierIcon(tierName: userTier),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== 프로그레스 바 (경험치 기반) =====
            if (!isPlatinum) _ProgressBar(completionRatio: expRatio),
            if (!isPlatinum) const SizedBox(height: 6),

            // ===== 프로그레스 바 하단: 현재 티어 경험치 정보 =====
            if (expProgress.tierMaxExp > 0)
              Align(
                alignment: Alignment.center,
                child: () {
                  if (isPlatinum) {
                    return Text(
                      '${expProgress.currentLocalExp} EXP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    );
                  }
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

            const SizedBox(height: 16),

            // ===== 전체 정답률 카드 (흰색 카드) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,                    // 🔥 카드 색 통일
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전체 정답률',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${accuracyPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4E7C88),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          totalQuizCount > 0
                              ? '지금까지 총 $totalQuizCount문제 중 '
                              '$correctQuizCount문제를\n맞혔어요.'
                              : '아직 푼 퀴즈가 없어요. 오늘 첫 문제를 풀어볼까요?',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== 🔥 정답률 아래로 이동한 주간 학습량 그래프 (흰색 카드) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,                    // 카드 색 통일
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    child: WeeklyStudyChart(
                      weeklyData: widget.weeklyData,
                      trendData: _accuracyTrend?.trend,   // 🔥 여기 추가
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 16),

            // ===== 카테고리별 푼 문제 수 (흰색 카드) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,                    // 🔥 카드 색 통일
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 학습량',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_categorySolved.isEmpty)
                    const Text(
                      '아직 카테고리별로 푼 문제가 없어요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B6B6B),
                      ),
                    )
                  else
                    Column(
                      children: _categorySolved.map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              Text(
                                '${c.solvedCount}문제',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== 많이 맞힌 / 많이 틀린 카테고리 (흰색 카드) =====
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,                    // 🔥 카드 색 통일
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리별 성과',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 많이 맞힌
                      Expanded(
                        child: _CategoryListCard(
                          title: '많이 맞힌 카테고리',
                          items: mostCorrectCategories,
                          emptyText: '아직 맞힌 기록이 없어요.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 많이 틀린
                      Expanded(
                        child: _CategoryListCard(
                          title: '많이 틀린 카테고리',
                          items: mostWrongCategories,
                          emptyText: '아직 틀린 기록이 없어요.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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

/// 🔥 카테고리 리스트(많이 맞힌/틀린) 공용 카드
class _CategoryListCard extends StatelessWidget {
  final String title;
  final List<CategoryPerformanceItem> items;
  final String emptyText;

  const _CategoryListCard({
    super.key,
    required this.title,
    required this.items,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final topItems = items.take(3).toList(); // 상위 3개만

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        if (topItems.isEmpty)
          Text(
            emptyText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
          )
        else
          Column(
            children: topItems.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                    Text(
                      '${e.count}회',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
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
    final String userTier = tierName;
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
