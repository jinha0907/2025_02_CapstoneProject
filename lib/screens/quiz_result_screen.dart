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
          child: Container(
            width: 375,
            height: 812,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFEDE8E3)),
            child: Stack(
              children: [
                // 🐯 캐릭터 이미지
                Positioned(
                  left: 110,
                  top: 80,
                  child: SizedBox(
                    width: 140,
                    height: 210,
                    child: Image.asset(
                      'assets/images/tiger_image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 타이틀
                const Positioned(
                  left: 100,
                  top: 310,
                  child: Text(
                    '오늘의 퀴즈 결과',
                    style: TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.27,
                    ),
                  ),
                ),

                // 요약 카드 배경
                Positioned(
                  left: 20,
                  top: 375,
                  child: Container(
                    width: 335,
                    height: 144,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // 전체 문제
                Positioned(
                  left: 36,
                  top: 393,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE8E3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Positioned(
                  left: 49,
                  top: 401,
                  child: Text(
                    'Q',
                    style: TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Positioned(
                  left: 88,
                  top: 401,
                  child: Text(
                    '전체 문제',
                    style: TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 327.5,
                  top: 401,
                  child: Text(
                    '${widget.total}',
                    style: const TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 구분선
                Positioned(
                  left: 22,
                  top: 447,
                  child: Container(
                    width: 331,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1, color: Color(0xFFEDE8E3)),
                      ),
                    ),
                  ),
                ),

                // 맞춘 문제
                Positioned(
                  left: 36,
                  top: 465,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE8E3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
                const Positioned(
                  left: 88,
                  top: 473,
                  child: Text(
                    '맞춘 문제',
                    style: TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 328,
                  top: 473,
                  child: Text(
                    '${widget.correct}',
                    style: const TextStyle(
                      color: Color(0xFF060710),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 확인 버튼
                Positioned(
                  left: 20,
                  top: 694,
                  child: GestureDetector(
                    onTap: () {
                      // ✅ 결과 확인 후 메인 화면으로 이동
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
