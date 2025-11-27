class QuizResultRequest {
  final int userId;
  final int correctCount;
  final int totalCount;
  final int score;
  final int quizId; // TODO: 나중에 실제 퀴즈 ID로 교체해야 함
  final int earnedExp;

  QuizResultRequest({
    required this.userId,
    required this.correctCount,
    required this.totalCount,
    required this.score,
    required this.quizId,
    required this.earnedExp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'score': score,
      'quizId': quizId,
      'earnedExp': earnedExp,
    };
  }
}
