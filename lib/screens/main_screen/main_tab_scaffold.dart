import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../info/user_info.dart';
import '../../router.dart';

import 'main_tab_body.dart';
import 'info_tab_body.dart';
import 'settings_tab_body.dart';
import 'learning_status_tab_body.dart';

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;

  String _name = '';
  String _tier = '';

  /// 주간 학습량(월~일)
  List<double> weeklyData = [2.5, 3.0, 4.2, 3.5, 5.0, 4.8, 3.3];

  void setWeeklyData(List<double> data) {
    if (data.length != 7) return;
    setState(() => weeklyData = data);
  }

  @override
  void initState() {
    super.initState();
    _updateUserInfo();
  }

  void _updateUserInfo() {
    final user = UserInfo.currentUser;
    if (user != null) {
      setState(() {
        _name = user.nickname;
        _tier = user.tier;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E3),

      // ===== 상단 + 탭 내용 =====
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            MainTabBody(
              name: _name,
              tier: _tier,
              weeklyData: weeklyData,
              // 🔸 라우팅은 여기서만 처리
              onTodayQuizTap: () => context.go(R.quiz),
            ),
            const InfoTabBody(),

            // ✅ 3번째: 학습 현황 탭 실제 화면 연결
            LearningStatusTabBody(
              weeklyData: weeklyData,
              tierName: _tier,       // 나중에 백엔드 값으로 교체 가능
              totalQuizCount: 30,      // 예시 값
              completionRatio: 0.3,    // 예: 전체 퀴즈 중 30% 완료
            ),

            const SettingsTabBody(),
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
              icon: _PillIcon(
                  icon: Icons.bar_chart_rounded, active: false),
              activeIcon: _PillIcon(
                  icon: Icons.bar_chart_rounded, active: true),
              label: '학습 현황',
            ),
            BottomNavigationBarItem(
              icon: _PillIcon(
                  icon: Icons.settings_outlined, active: false),
              activeIcon: _PillIcon(
                  icon: Icons.settings_outlined, active: true),
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
