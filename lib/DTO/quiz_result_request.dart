class QuizResultRequest {
  final int userId;
  final int quizId;
  final int correctCount;
  final int totalCount;
  final int score;
  final int earnedExp;

  QuizResultRequest({
    required this.userId,
    required this.quizId,
    required this.correctCount,
    required this.totalCount,
    required this.score,
    required this.earnedExp,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "quizId": quizId,
      "correctCount": correctCount,
      "totalCount": totalCount,
      "score": score,
      "earnedExp": earnedExp,
    };
  }
}
