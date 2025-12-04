// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../api/quiz_api.dart';
import '../DTO/quiz_load.dart'; // QuizLoadItem
import '../DTO/quiz_result_request.dart'; // 🔹 QuizResultItem 사용
import '../info/user_info.dart';

/// ===== 모델 =====
class Choice {
  final String text;
  final String explanation;
  final bool isAnswer;
  const Choice(this.text, {required this.explanation, this.isAnswer = false});
}

class Question {
  final int quizId; // 🔹 서버의 quizId
  final String title;
  final List<Choice> choices;

  const Question({
    required this.quizId,
    required this.title,
    required this.choices,
  });

  int get answerIndex => choices.indexWhere((c) => c.isAnswer);
}

/// ===== 컨트롤러 =====
enum QuizStage { question, feedback }

class QuizController {
  final List<Question> questions;

  int index = 0;
  int? selected; // 화면에 현재 보이는 선택
  int? firstSelected; // ✅ 채점에 쓰일 '처음 선택'
  int correctCount = 0;
  QuizStage stage = QuizStage.question;

  // 🔹 각 문제별 "처음 선택이 정답이었는지" 기록
  final List<bool> firstCorrectList;

  QuizController(this.questions)
      : firstCorrectList = List<bool>.filled(questions.length, false);

  Question get q => questions[index];
  int get total => questions.length;
  bool get isLast => index == total - 1;
  bool get hasSelection => selected != null;
  bool get isCorrectNow =>
      selected != null && selected == q.answerIndex; // 화면 표시용
  bool get isFirstCorrect =>
      firstSelected != null && firstSelected == q.answerIndex; // 채점용
  double get progress => (index + 1) / total;
  Choice? get selectedChoice =>
      (selected == null) ? null : q.choices[selected!];

  /// ✅ 언제든 다른 선지로 변경 가능
  /// 처음 선택일 때만 firstSelected를 기록(채점에 사용)
  void select(int i) {
    if (stage == QuizStage.question) {
      stage = QuizStage.feedback;
    }
    selected ??= i; // 화면 첫 선택 기록
    firstSelected ??= i; // 채점용 첫 선택 기록(이미 있으면 유지)
    selected = i; // 화면용 현재 선택은 언제든 변경 가능
  }

  /// ✅ 다음 문제로 진행(채점은 '처음 선택' 기준)
  bool next() {
    if (stage != QuizStage.feedback) return false;

    // 현재 문제의 정답 여부 기록
    final bool firstWasCorrect = isFirstCorrect;
    firstCorrectList[index] = firstWasCorrect;

    if (firstWasCorrect) {
      correctCount++;
    }

    if (isLast) {
      // 마지막 문제면 true 리턴 → 결과 화면으로 이동
      return true;
    }

    index++;
    selected = null;
    firstSelected = null; // 다음 문제에서 다시 초기화
    stage = QuizStage.question;
    return false;
  }

  /// 🔹 /quiz/result 에 보낼 results 리스트 생성
  List<QuizResultItem> buildResultItems() {
    return List<QuizResultItem>.generate(questions.length, (i) {
      return QuizResultItem(
        quizId: questions[i].quizId,
        correct: firstCorrectList[i],
      );
    });
  }
}

/// ===== 화면 =====
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizController c;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizFromApi();
  }

  Future<void> _loadQuizFromApi() async {
    try {
      final int userId = UserInfo.currentUser!.userId;
      final List<QuizLoadItem> items = await QuizApi.loadQuiz(userId);

      // 서버가 빈 리스트를 줄 수도 있으니 방어
      if (items.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = '오늘 풀 수 있는 퀴즈가 없습니다.';
          _isLoading = false;
        });
        return;
      }

      // 🔁 QuizLoadItem -> Question/Choice 변환
      final questions = items.map((item) {
        final List<String> choices = item.choices;
        final List<String> explanations = item.explanations;

        final choiceModels = <Choice>[];

        for (int i = 0; i < choices.length; i++) {
          final text = choices[i];
          final explain = (i < explanations.length) ? explanations[i] : '';

          final isAnswer = text == item.answer;

          choiceModels.add(
            Choice(
              text,
              explanation: explain,
              isAnswer: isAnswer,
            ),
          );
        }

        return Question(
          quizId: item.quizHeader.quizId, // 🔹 quizId 전달
          title: item.question,
          choices: choiceModels,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        c = QuizController(questions);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _optionBg(int i) {
    if (c.stage == QuizStage.feedback && c.selected != null) {
      if (i == c.selected) {
        return c.isCorrectNow
            ? const Color(0xFF6D9E8D)
            : const Color(0xFFCC8275);
      }
    }
    return const Color(0xFFF4F3F6);
  }

  void _onTapChoice(int i) {
    setState(() => c.select(i));
  }

  void _onTapNext() {
    if (c.stage != QuizStage.feedback) return;
    final goResult = c.next();
    if (goResult && mounted) {
      // ✅ 점수/문항 수 + 문제별 결과를 함께 결과 화면으로 전달
      final results = c.buildResultItems();

      context.go(
        R.quizResult,
        extra: {
          'total': c.total,
          'correct': c.correctCount,
          'results': results,
        },
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEDE8E3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEDE8E3),
        body: Center(
          child: Text(
            '퀴즈를 불러오는 중 오류가 발생했습니다.\n$_errorMessage',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 여기부터는 c가 준비된 상태
    const double totalBarWidth = 300;
    final double filledWidth = totalBarWidth * c.progress;
    final bool nextEnabled =
        c.stage == QuizStage.feedback && c.hasSelection;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE8E3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 375,
            height: 812,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFEDE8E3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    '오늘의 퀴즈',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 진행바 + 인덱스
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: totalBarWidth,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F3F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          Container(
                            width: filledWidth.clamp(0, totalBarWidth),
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4E7C88),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${c.index + 1}/${c.total}',
                        style: const TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 내용 전체 영역 (문제 + 해설 + 선지)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 문제
                                  Text(
                                    c.q.title,
                                    style: const TextStyle(
                                      color: Color(0xFF2C2C2C),
                                      fontSize: 17,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // 피드백 패널
                                  if (c.stage == QuizStage.feedback &&
                                      c.selectedChoice != null)
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 120,
                                        maxHeight:
                                        160, // 이전보다 조금 줄여서 공간 확보
                                      ),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: c.isCorrectNow
                                            ? const Color(0xFF6D9E8D)
                                            : const Color(0xFFCC8275),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/tiger_image.png',
                                            width: 60,
                                            height: 120,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                c.selectedChoice!.explanation,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.54,
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // 🔹 남는 공간은 비워두고 선지를 아래로 밀기
                                  const Spacer(),

                                  // 선지들 (아래쪽에 붙음)
                                  Column(
                                    children: List.generate(
                                      c.q.choices.length,
                                          (i) => Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 12),
                                        child: _OptionTile(
                                          letter:
                                          String.fromCharCode(65 + i),
                                          text: c.q.choices[i].text,
                                          color: _optionBg(i),
                                          isSelected: c.selected == i,
                                          onTap: () => _onTapChoice(i),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: GestureDetector(
                    onTap: nextEnabled ? _onTapNext : null,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: nextEnabled
                            ? const Color(0xFF4E7C88)
                            : const Color(0xFFB0BEC5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (c.isLast && c.stage == QuizStage.feedback)
                            ? '결과 보기'
                            : '계속',
                        style: const TextStyle(
                          color: Color(0xFFF4F3F6),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
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

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 335,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8E3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 18,
                color: Color(0xFF4E7C88),
              )
                  : Text(
                letter,
                style: const TextStyle(
                  color: Color(0xFF060710),
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
