class UserResponse {
  final int userId;
  final String email;
  final String nickname;
  final String tier;
  final int totalExp;
  final String difficulty;
  final int questionCount;

  UserResponse({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.tier,
    required this.totalExp,
    required this.difficulty,
    required this.questionCount,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'],
      email: json['email'],
      nickname: json['nickname'],
      tier: json['tier'],
      totalExp: json['totalExp'],
      difficulty: json['difficulty'],
      questionCount: json['questionCount'],
    );
  }
}
