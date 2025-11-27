import 'package:flutter/material.dart';

class AmountSettingScreen extends StatefulWidget {
  const AmountSettingScreen({super.key});

  @override
  State<AmountSettingScreen> createState() => _AmountSettingScreenState();
}

class _AmountSettingScreenState extends State<AmountSettingScreen> {
  int? _selectedAmount;

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
                crossAxisAlignment: CrossAxisAlignment.center, // ★ 세로 중앙 정렬
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 120,  // 원하면 크기 조절 가능
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),

                  // 텍스트를 호랑이 가운데에 맞추기 위해 Center로 감싸기
                  Expanded(
                    child: Center(
                      child: Text(
                        '하루 퀴즈 문제 분량을\n설정할게요!',  // 원하는 텍스트
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
                isSelected: _selectedAmount == 3,
                onTap: () => setState(() => _selectedAmount = 3),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '5 문제',
                isSelected: _selectedAmount == 5,
                onTap: () => setState(() => _selectedAmount = 5),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '7 문제',
                isSelected: _selectedAmount == 7,
                onTap: () => setState(() => _selectedAmount = 7),
              ),
              const SizedBox(height: 10),
              _AmountOption(
                label: '9 문제',
                isSelected: _selectedAmount == 9,
                onTap: () => setState(() => _selectedAmount = 9),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedAmount == null
                      ? null
                      : () {
                    // TODO: 여기서 선택한 분량 저장
                    // 예) context.read<Settings>().setDailyAmount(_selectedAmount);
                    Navigator.pop(context); // 설정 탭 첫 화면으로 돌아가기
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

class _AmountOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountOption({
    required this.label,
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
        width: double.infinity, // 가로는 부모 너비를 꽉 채움
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
              textAlign: TextAlign.center, // 가운데 정렬
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
