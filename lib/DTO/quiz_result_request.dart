// lib/DTO/quiz_result_request.dart

class QuizResultItem {
  final int quizId;
  final bool correct; // ✅ 처음 선택이 정답이었는지 여부

  QuizResultItem({
    required this.quizId,
    required this.correct,
  });

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'correct': correct,
  };
}

class QuizResultRequest {
  final int userId;
  final List<QuizResultItem> results; // ✅ 문제별 결과 리스트
  final int totalCount;               // 전체 문항 수
  final int score;                    // 점수 (예: 맞춘 개수)
  final int earnedExp;                // 획득 경험치

  QuizResultRequest({
    required this.userId,
    required this.results,
    required this.totalCount,
    required this.score,
    required this.earnedExp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'results': results.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'score': score,
      'earnedExp': earnedExp,
    };
  }
}
