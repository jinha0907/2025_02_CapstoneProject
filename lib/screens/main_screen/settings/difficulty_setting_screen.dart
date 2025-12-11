import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../api/settings_api.dart';
import '../../../info/user_info.dart';

class DifficultySettingScreen extends StatefulWidget {
  const DifficultySettingScreen({super.key});

  @override
  State<DifficultySettingScreen> createState() =>
      _DifficultySettingScreenState();
}

class _DifficultySettingScreenState extends State<DifficultySettingScreen> {
  String? _selectedDifficulty;
  bool _isSaving = false;

  static const _primaryColor = Color(0xFF4E7C88);

  @override
  void initState() {
    super.initState();
    // ✅ 현재 사용자 설정 값을 초기 선택값으로 지정 (대문자/소문자 섞여 와도 처리)
    final raw = UserInfo.currentUser?.difficulty;
    _selectedDifficulty = raw?.toLowerCase(); // 'EASY' -> 'easy' 등으로 통일
  }

  Future<void> _saveSettings() async {
    if (_selectedDifficulty == null) return;
    final userId = UserInfo.currentUser?.userId;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await SettingsApi.updateDifficulty(
        userId: userId,
        difficulty: _selectedDifficulty!, // 'easy' / 'normal' / 'hard' 전송
      );

      if (response != null && mounted) {
        // 성공 시 화면 닫기
        context.pop();
      } else {
        // TODO: 실패 UI 처리 (예: 스낵바)
      }
    } catch (e) {
      // TODO: 에러 UI 처리
      print('난이도 설정 저장 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
              // ✅ 상단 호랑이 + 텍스트 (앞에서 통일한 버전 유지)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 110,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Center(
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

              // 선택지들
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _DifficultyOption(
                      title: 'EASY: 한국 사회 초입이라면 이 단계부터\n            가볍게 시작해요!',
                      value: 'easy',
                      groupValue: _selectedDifficulty,
                      onChanged: (v) => setState(() => _selectedDifficulty = v),
                    ),
                    const SizedBox(height: 20),
                    _DifficultyOption(
                      title: 'NORMAL: 어느 정도 익숙하면 이 난이도가\n                   잘 맞아요!',
                      value: 'normal',
                      groupValue: _selectedDifficulty,
                      onChanged: (v) => setState(() => _selectedDifficulty = v),
                    ),
                    const SizedBox(height: 20),
                    _DifficultyOption(
                      title: 'HARD: 한국 사회를 꽤 잘 알아야\n             풀 수 있어요!',
                      value: 'hard',
                      groupValue: _selectedDifficulty,
                      onChanged: (v) => setState(() => _selectedDifficulty = v),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDifficulty == null || _isSaving
                      ? null
                      : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.4),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _DifficultyOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final borderColor =
    isSelected ? const Color(0xFF4E7C88) : const Color(0xFFB0A69A);
    final bgColor = isSelected ? const Color(0xFF4E7C88) : Colors.white;
    final titleColor = isSelected ? Colors.white : Colors.black87;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: double.infinity,
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
