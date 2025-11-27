class QuizResultResponse {
  final String resultMessage;
  final int totalExp;
  final String currentTier;

  QuizResultResponse({
    required this.resultMessage,
    required this.totalExp,
    required this.currentTier,
  });

  factory QuizResultResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultResponse(
      resultMessage: json["resultMessage"],
      totalExp: json["totalExp"],
      currentTier: json["currentTier"],
    );
  }
}
