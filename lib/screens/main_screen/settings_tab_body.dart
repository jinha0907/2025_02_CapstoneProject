import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';  // ← lib/router.dart 경로 (settings 폴더 기준)
import '../../info/user_info.dart'; // 🔥 로그아웃 시 세션 초기화용

class SettingsTabBody extends StatelessWidget {
  const SettingsTabBody({super.key});

  static const _primaryColor = Color(0xFF4E7C88);
  static const _cardColor = Color(0xFFD7CEC3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE8E3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

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

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  UserInfo.clear();
                  context.go(R.login);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SettingsTabBody._primaryColor),  // 테두리 = 글자색
                  backgroundColor: SettingsTabBody._primaryColor,                // 내부 = 글자색
                  foregroundColor: Colors.white,                                 // 글씨 = 흰색
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,  // 글씨 흰색
                  ),
                ),
              ),
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 내부 흰색
            borderRadius: BorderRadius.circular(16),
            // 🔥 테두리 제거 — 기존 Border.all 삭제
          ),
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
    );
  }
}

