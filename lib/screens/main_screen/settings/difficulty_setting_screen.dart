import 'package:flutter/material.dart';

class DifficultySettingScreen extends StatefulWidget {
  const DifficultySettingScreen({super.key});

  @override
  State<DifficultySettingScreen> createState() =>
      _DifficultySettingScreenState();
}

class _DifficultySettingScreenState extends State<DifficultySettingScreen> {
  String? _selectedDifficulty;

  static const _primaryColor = Color(0xFF4E7C88);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE8E3),
        elevation: 0,
        centerTitle: true,
        title: const SizedBox.shrink(),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 호랑이 + 텍스트
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,   // ★ 세로 중앙 정렬
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 100,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Center(                      // ★ 텍스트를 세로 중앙으로 이동
                      child: Text(
                        '맞춤형 퀴즈 난이도를\n설정할게요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 선택지들: 화면 양쪽 10 여백만 두기
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _DifficultyOption(
                      title: '쉬운 난이도: 기본적인 상식 문제 위주의 퀴즈',
                      isSelected: _selectedDifficulty == 'easy',
                      onTap: () =>
                          setState(() => _selectedDifficulty = 'easy'),
                    ),
                    const SizedBox(height: 20),
                    _DifficultyOption(
                      title: '보통 난이도: 기본 상식과 중간 수준의 퀴즈',
                      isSelected: _selectedDifficulty == 'normal',
                      onTap: () =>
                          setState(() => _selectedDifficulty = 'normal'),
                    ),
                    const SizedBox(height: 20),
                    _DifficultyOption(
                      title: '어려운 난이도: 어려운 수준의 상식 퀴즈',
                      isSelected: _selectedDifficulty == 'hard',
                      onTap: () =>
                          setState(() => _selectedDifficulty = 'hard'),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDifficulty == null
                      ? null
                      : () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.4),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    isSelected ? const Color(0xFF4E7C88) : const Color(0xFFB0A69A);
    final bgColor = isSelected ? const Color(0xFF4E7C88) : Colors.white;
    final titleColor = isSelected ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: double.infinity,       // ← ← ← ★ 가로 전체 채움 (핵심)
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

