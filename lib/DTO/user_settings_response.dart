class UserSettingsResponse {
  final String difficulty;
  final int questionCount;

  UserSettingsResponse({
    required this.difficulty,
    required this.questionCount,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UserSettingsResponse(
      difficulty: json['difficulty'] as String,
      questionCount: json['questionCount'] as int,
    );
  }
}
