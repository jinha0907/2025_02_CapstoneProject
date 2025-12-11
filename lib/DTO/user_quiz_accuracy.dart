// lib/DTO/user_quiz_accuracy.dart

class UserQuizAccuracy {
  final int userId;
  final int totalQuizzes;
  final int correctQuizzes;
  /// 서버에서 내려주는 accuracy (지금 예시를 보면 0~1 범위)
  final double accuracy;

  UserQuizAccuracy({
    required this.userId,
    required this.totalQuizzes,
    required this.correctQuizzes,
    required this.accuracy,
  });

  factory UserQuizAccuracy.fromJson(Map<String, dynamic> json) {
    return UserQuizAccuracy(
      userId: json['userId'] as int? ?? 0,
      totalQuizzes: json['totalQuizzes'] as int? ?? 0,
      correctQuizzes: json['correctQuizzes'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalQuizzes': totalQuizzes,
      'correctQuizzes': correctQuizzes,
      'accuracy': accuracy,
    };
  }

  /// UI용: 퍼센트(0~100)로 변환
  /// 예시 JSON에서 accuracy가 0.722 이런 식이라 0~1 기준으로 처리
  double get accuracyPercent => accuracy * 100.0;
}
