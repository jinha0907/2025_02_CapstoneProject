import 'package:flutter/material.dart';
import 'package:korean_culture_quiz/widgets/weekly_study_chart.dart';
import 'package:korean_culture_quiz/DTO/quiz_stats.dart';

class MainTabBody extends StatelessWidget {
  final String name;
  final String tier;
  final List<WeeklyQuizCount> weeklyData;
  final VoidCallback onTodayQuizTap; // 오늘의 퀴즈 탭 콜백

  // 🔥 추가: 메인 화면에서 학습 현황 차트 카드를 탭했을 때 학습현황 탭으로 전환하는 콜백
  final VoidCallback onLearningStatusTap;

  const MainTabBody({
    super.key,
    required this.name,
    required this.tier,
    required this.weeklyData,
    required this.onTodayQuizTap,
    required this.onLearningStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 상단: 환영합니다 =====
          Row(
            children: const [
              Icon(Icons.wb_sunny_outlined,
                  size: 18, color: Color(0xFF6B6B6B)),
              SizedBox(width: 6),
              Text(
                '환영합니다!',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ===== 헤더 =====
          _HeaderSection(
            name: name,
            tierCard: _InfoCard(
              leading: const SizedBox.shrink(),
              title: '내 티어: $tier',
              titleWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '내 티어: $tier',
                    style: const TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('🌱', style: TextStyle(fontSize: 26)),
                ],
              ),
              subtitle: '퀴즈를 풀어 단계를 올려보세요!',
              onTap: () {},
              showChevron: false,
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            ),
          ),

          const SizedBox(height: 16),

          // ===== 오늘의 퀴즈 카드 =====
          _InfoCard(
            leading: const _LargeEmoji(emoji: '🎓'),
            title: '오늘의 퀴즈',
            subtitle: '한국 사회 전반에 대한 정보를 담은 퀴즈!',
            onTap: onTodayQuizTap,
            showChevron: false,
            backgroundColor: Colors.white,
          ),

          const SizedBox(height: 12),

          // ===== 학습 현황 =====
          _ChartCard(
            title: '내 학습 현황',
            child: WeeklyStudyChart(weeklyData: weeklyData),

            // 🔥 차트 카드 전체를 탭하면 → 학습현황 탭으로 이동
            onTap: onLearningStatusTap,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// ===== 상단 헤더 =====
class _HeaderSection extends StatelessWidget {
  final String name;
  final Widget tierCard;
  const _HeaderSection({required this.name, required this.tierCard});

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 180;
    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  child: Image.asset(
                    'assets/images/tiger_image.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    height: 90,
                    child: tierCard,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFB7D3D9),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C2C2C),
                    fontWeight: FontWeight.w700,
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

/// ===== 카드 공통 =====
class _InfoCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? titleWidget;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color backgroundColor;
  final EdgeInsets contentPadding;

  const _InfoCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.titleWidget,
    this.onTap,
    this.showChevron = true,
    this.backgroundColor = const Color(0xFFF6F1EB),
    this.contentPadding =
    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: contentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading,
              if (leading is! SizedBox) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget ??
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 13,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showChevron)
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9B9B9B)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== 그래프 카드 =====
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const _ChartCard({
    required this.title,
    required this.child,
    this.onTap,
    this.backgroundColor = const Color(0xFFF6F1EB),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9B9B9B)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeEmoji extends StatelessWidget {
  final String emoji;
  const _LargeEmoji({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 56),
    );
  }
}

class _EmojiBadge extends StatelessWidget {
  final String emoji;
  const _EmojiBadge({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Text(
        emoji,
        style: const TextStyle(
          fontSize: 30,
        ),
      ),
    );
  }
}
