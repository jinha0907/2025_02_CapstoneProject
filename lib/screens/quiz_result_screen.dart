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

  const QuizResultScreen({
    super.key,
    this.total = 2, // 기본값 (직접 접근 시 대비)
    this.correct = 1,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    _submitResult();
  }

  Future<void> _submitResult() async {
    final user = UserInfo.currentUser;
    if (user == null) return;

    try {
      final request = QuizResultRequest(
        userId: user.userId,
        correctCount: widget.correct,
        totalCount: widget.total,
        score: widget.correct, // 맞춘 문제를 점수로 사용
        quizId: 10, // TODO: 나중에 실제 퀴즈 ID로 교체해야 함
        earnedExp: 10, // 획득 경험치는 10으로 고정
      );

      final response = await QuizApi.submitQuizResult(request);

      // UserInfo 업데이트
      final updatedUser = UserResponse(
        userId: user.userId,
        email: user.email,
        nickname: user.nickname,
        tier: response.currentTier, // Tier 업데이트
        totalExp: response.totalExp, // Exp 업데이트
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
