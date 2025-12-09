import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../info/user_info.dart';
import '../../router.dart';

import 'main_tab_body.dart';
import 'info_tab_body.dart';
import 'settings_tab_body.dart';
import 'learning_status_tab_body.dart';

import '../../api/quiz_api.dart';
import '../../DTO/quiz_stats.dart';

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;

  String _name = '';
  String _tier = '';

  /// 주간 학습량(월~일) - 🔥 이제 DTO 리스트로 관리
  List<WeeklyQuizCount> weeklyData = const [];

  /// 전체 푼 퀴즈 개수
  int _totalQuizCount = 0;

  /// 학습 달성도(0.0~1.0)
  double _completionRatio = 0.0;

  bool _loadingStats = true;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _updateUserInfo();
    _loadQuizStats();
  }

  void _updateUserInfo() {
    final user = UserInfo.currentUser;
    if (user != null) {
      setState(() {
        _name = user.nickname;
        _tier = user.tier; // 예: "BRONZE", "SILVER" 등
      });
    }
  }

  Future<void> _loadQuizStats() async {
    try {
      setState(() {
        _loadingStats = true;
        _statsError = null;
      });

      // 주간 + 전체 병렬 호출
      final weeklyFuture = QuizApi.fetchWeeklyQuizCounts();
      final totalFuture = QuizApi.fetchTotalQuizCount();

      final results = await Future.wait([
        weeklyFuture,
        totalFuture,
      ]);

      final List<WeeklyQuizCount> weeklyList =
      results[0] as List<WeeklyQuizCount>;
      final int totalCount = results[1] as int;

      // 🔹 주간 데이터 정렬 (오래된 날짜 → 최신 날짜)
      final List<WeeklyQuizCount> sortedWeekly = [...weeklyList]
        ..sort((a, b) => a.date.compareTo(b.date));

      // 🔹 최대 7개만 사용 (데이터가 더 많을 경우, 최근 7일만)
      List<WeeklyQuizCount> limitedWeekly;
      if (sortedWeekly.length <= 7) {
        limitedWeekly = sortedWeekly;
      } else {
        limitedWeekly =
            sortedWeekly.sublist(sortedWeekly.length - 7); // 뒤에서 7개
      }

      // 🔹 completionRatio 계산 (유저 목표 questionCount 기준)
      final user = UserInfo.currentUser;
      double completion = 0.0;
      if (user != null && user.questionCount > 0) {
        completion = totalCount / user.questionCount;
      }

      setState(() {
        weeklyData = limitedWeekly;            // 🔥 DTO 그대로 저장
        _totalQuizCount = totalCount;
        _completionRatio = completion.clamp(0.0, 1.0);
        _loadingStats = false;
      });
    } catch (e) {
      setState(() {
        _loadingStats = false;
        _statsError = '학습 통계를 불러오지 못했습니다.\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 통계 로딩 중이어도 기본 UI는 보여주고 숫자만 나중에 갱신되게 놔두는 쪽으로 갈게
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E3),
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                MainTabBody(
                  name: _name,
                  tier: _tier,
                  weeklyData: weeklyData, // ✅ DTO 리스트 전달
                  onTodayQuizTap: () => context.go(R.quiz),

                  // 🔥 메인 화면의 학습 현황 차트 카드 탭 시 → 학습현황 탭으로 이동
                  onLearningStatusTap: () {
                    setState(() {
                      _currentIndex = 2; // 0: 메인, 1: 정보, 2: 학습 현황, 3: 설정
                    });
                  },
                ),
                const InfoTabBody(),
                LearningStatusTabBody(
                  weeklyData: weeklyData,       // ✅ 여기도 타입 맞게 DTO 리스트
                  tierName: _tier,
                  totalQuizCount: _totalQuizCount,
                  completionRatio: _completionRatio,
                ),
                const SettingsTabBody(),
              ],
            ),

            // 에러 표시 (필요하면)
            if (_statsError != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _statsError!,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // ===== 하단 네비게이션 =====
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEDE8E2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2C2C2C),
          unselectedItemColor: const Color(0xFF6D6D6D),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: _PillIcon(icon: Icons.home_rounded, active: false),
              activeIcon: _PillIcon(icon: Icons.home_rounded, active: true),
              label: '메인',
            ),
            BottomNavigationBarItem(
              icon: _PillIcon(icon: Icons.lightbulb_outline, active: false),
              activeIcon:
              _PillIcon(icon: Icons.lightbulb_outline, active: true),
              label: '정보 모음',
            ),
            BottomNavigationBarItem(
              icon: _PillIcon(icon: Icons.bar_chart_rounded, active: false),
              activeIcon:
              _PillIcon(icon: Icons.bar_chart_rounded, active: true),
              label: '학습 현황',
            ),
            BottomNavigationBarItem(
              icon: _PillIcon(icon: Icons.settings_outlined, active: false),
              activeIcon:
              _PillIcon(icon: Icons.settings_outlined, active: true),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}

/// 하단 네비 아이콘 Pill 스타일
class _PillIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _PillIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    const pillColor = Color(0xFF4E7C88);
    final iconColor = active ? Colors.white : const Color(0xFF6D6D6D);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: active ? 12 : 0,
        vertical: active ? 6 : 0,
      ),
      decoration: BoxDecoration(
        color: active ? pillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
