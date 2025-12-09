// lib/screens/quiz_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../DTO/quiz_result_request.dart';
import '../DTO/user_response.dart';
import '../api/quiz_api.dart';
import '../info/user_info.dart';
import '../router.dart';

class QuizResultScreen extends StatefulWidget {
  final int total;
  final int correct;
  final List<QuizResultItem> results; // 🔹 문제별 결과 리스트

  const QuizResultScreen({
    super.key,
    this.total = 2, // 기본값 (직접 접근 시 대비)
    this.correct = 1,
    this.results = const [],
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  // 🔹 난이도별 "문제당 EXP" 상수
  static const int _expPerQuestionEasy = 10;
  static const int _expPerQuestionNormal = 20;
  static const int _expPerQuestionHard = 30;

  @override
  void initState() {
    super.initState();
    _submitResult();
  }

  /// 🔹 난이도(EASY/NORMAL/HARD)에 따른 "문제당" EXP
  int _expPerQuestionByDifficulty(String? difficulty) {
    if (difficulty == null) {
      return _expPerQuestionEasy; // 기본값
    }

    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return _expPerQuestionEasy;
      case 'NORMAL':
        return _expPerQuestionNormal;
      case 'HARD':
        return _expPerQuestionHard;
      default:
        return _expPerQuestionEasy;
    }
  }

  Future<void> _submitResult() async {
    final user = UserInfo.currentUser;
    if (user == null) return;

    try {
      // ✅ 실제 맞춘 문제 수 계산
      //  - widget.results 에서 correct == true 인 것만 세기
      //  - 혹시 results가 비어 있으면 fallback 으로 widget.correct 사용
      int correctCount;
      if (widget.results.isNotEmpty) {
        correctCount =
            widget.results.where((r) => r.correct).length;
      } else {
        correctCount = widget.correct;
      }

      // ✅ 난이도에 따른 문제당 EXP
      final int expPerQuestion =
      _expPerQuestionByDifficulty(user.difficulty);

      // ✅ 최종 획득 EXP = 맞춘 문제 수 × 문제당 EXP
      final int earnedExp = correctCount * expPerQuestion;

      final request = QuizResultRequest(
        userId: user.userId,
        results: widget.results,
        totalCount: widget.total,
        score: correctCount, // 점수도 맞춘 개수 기반으로 통일
        earnedExp: earnedExp,
      );

      final response = await QuizApi.submitQuizResult(request);

      // UserInfo 업데이트 (서버에서 계산된 최종 totalExp, tier 반영)
      final updatedUser = UserResponse(
        userId: user.userId,
        email: user.email,
        nickname: user.nickname,
        tier: response.currentTier,
        totalExp: response.totalExp,
        difficulty: user.difficulty,
        questionCount: user.questionCount,
      );

      UserInfo.setUser(updatedUser);
    } catch (e) {
      // TODO: 에러 처리 (예: 스낵바 표시)
      print('퀴즈 결과 전송/처리 실패: $e');
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEDE8E3),
    body: SafeArea(
      child: Center(
        child: SizedBox(
          width: 375,
          height: 812,
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 140,
                height: 210,
                child: Image.asset(
                  'assets/images/tiger_image.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '오늘의 퀴즈 결과',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.27,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 335,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _ResultRow(
                      icon: 'Q',
                      label: '전체 문제',
                      value: '${widget.total}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                      ),
                      child: Container(
                        height: 1,
                        color: const Color(0xFFEDE8E3),
                      ),
                    ),
                    _ResultRow(
                      icon: Icons.check,
                      label: '맞춘 문제',
                      value: '${widget.correct}',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: GestureDetector(
                  onTap: () {
                    context.go(R.main);
                  },
                  child: Container(
                    width: 335,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E7C88),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFFF4F3F6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _ResultRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8E3),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: icon is String
                ? Text(
                    icon as String,
                    style: const TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(
                    icon as IconData,
                    color: Colors.black,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF060710),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF060710),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
