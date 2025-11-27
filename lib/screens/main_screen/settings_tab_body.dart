import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';  // ← lib/router.dart 경로 (settings 폴더 기준)

// 이 파일에서는 실제 화면 위젯(DifficultySettingScreen, AmountSettingScreen)을
// 직접 push 하지 않고, 라우팅(R.difficulty / R.amountSetting)만 사용하므로
// 아래 두 import는 더 이상 필요 없음 (원하면 지워도 됨).
// import 'settings/difficulty_setting_screen.dart';
// import 'settings/amount_setting_screen.dart';

class SettingsTabBody extends StatelessWidget {
  const SettingsTabBody({super.key});

  static const _primaryColor = Color(0xFF4E7C88);
  static const _cardColor = Color(0xFFD7CEC3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8E3),
      child: Padding(
        // 왼쪽 패딩을 16 -> 8 로 줄여서 전체적으로 더 붙게
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 호랑이를 살짝 왼쪽으로 당겨서 PNG 안쪽 여백(13px)을 보정
                Transform.translate(
                  offset: const Offset(-6, 0), // 왼쪽으로 6px 이동
                  child: Image.asset(
                    'assets/images/tiger_image.png',
                    width: 100,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),

                // 호랑이와 카드 사이 여백도 16 -> 6 정도로 축소
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
                          '설정 페이지',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '난이도 및 문제 분량 설정 페이지',
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

            const SizedBox(height: 20),

            _MenuCard(
              label: '퀴즈 난이도 설정',
              description: '쉬움 / 보통 / 어려움 중에서 선택해요.',
              icon: Icons.school_outlined,
              onTap: () {
                // ✅ 이전: Navigator.of(context).push(MaterialPageRoute(...))
                // ✅ 지금: go_router 라우팅
                context.push(R.difficulty);
              },
            ),
            const SizedBox(height: 12),
            _MenuCard(
              label: '하루 퀴즈 분량 설정',
              description: '하루에 풀 문제 개수를 정해요.',
              icon: Icons.list_alt_outlined,
              onTap: () {
                context.push(R.amountSetting);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: SettingsTabBody._cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFB0A696),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 26, color: const Color(0xFF2C2C2C)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF4A4A4A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
