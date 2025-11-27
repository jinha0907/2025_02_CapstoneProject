class UserSettingsRequest {
  final String difficulty;
  final int questionCount;

  UserSettingsRequest({
    required this.difficulty,
    required this.questionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'questionCount': questionCount,
    };
  }
}
