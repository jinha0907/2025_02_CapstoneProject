import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../api/settings_api.dart';
import '../../../info/user_info.dart';

class AmountSettingScreen extends StatefulWidget {
  const AmountSettingScreen({super.key});

  @override
  State<AmountSettingScreen> createState() => _AmountSettingScreenState();
}

class _AmountSettingScreenState extends State<AmountSettingScreen> {
  int? _selectedAmount;
  bool _isSaving = false;

  static const _primaryColor = Color(0xFF4E7C88);

  @override
  void initState() {
    super.initState();
    _selectedAmount = UserInfo.currentUser?.questionCount;
  }

  Future<void> _saveSettings() async {
    if (_selectedAmount == null) return;
    final userId = UserInfo.currentUser?.userId;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await SettingsApi.updateQuestionCount(
        userId: userId,
        count: _selectedAmount!,
      );

      if (response != null && mounted) {
        context.pop();
      } else {
        // TODO: 실패 UI 처리
      }
    } catch (e) {
      print('학습량 설정 저장 실패: $e');
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
              // 상단 호랑이 + 텍스트
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '하루 퀴즈 문제 분량을\n설정할게요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ===== 분량 선택 옵션들 =====
              _AmountOption(
                label: '3 문제',
                value: 3,
                groupValue: _selectedAmount,
                onChanged: (v) => setState(() => _selectedAmount = v),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '5 문제',
                value: 5,
                groupValue: _selectedAmount,
                onChanged: (v) => setState(() => _selectedAmount = v),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '7 문제',
                value: 7,
                groupValue: _selectedAmount,
                onChanged: (v) => setState(() => _selectedAmount = v),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '9 문제',
                value: 9,
                groupValue: _selectedAmount,
                onChanged: (v) => setState(() => _selectedAmount = v),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedAmount == null || _isSaving
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
class _AmountOption extends StatelessWidget {
  final String label;
  final int value;
  final int? groupValue;
  final ValueChanged<int?> onChanged;

  const _AmountOption({
    required this.label,
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
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
