// lib/DTO/quiz_accuracy_trend.dart

class AccuracyTrendPoint {
  final DateTime date;
  final int total;
  final int correct;
  final double accuracy; // 0~1

  AccuracyTrendPoint({
    required this.date,
    required this.total,
    required this.correct,
    required this.accuracy,
  });

  factory AccuracyTrendPoint.fromJson(Map<String, dynamic> json) {
    return AccuracyTrendPoint(
      date: DateTime.parse(json['date'] as String),
      total: json['total'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T').first,
      'total': total,
      'correct': correct,
      'accuracy': accuracy,
    };
  }

  double get accuracyPercent => accuracy * 100.0;
}

class UserAccuracyTrend {
  final int userId;
  final int periodDays;
  final List<AccuracyTrendPoint> trend;

  UserAccuracyTrend({
    required this.userId,
    required this.periodDays,
    required this.trend,
  });

  factory UserAccuracyTrend.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['trend'] as List<dynamic>? ?? [];
    return UserAccuracyTrend(
      userId: json['userId'] as int? ?? 0,
      periodDays: json['periodDays'] as int? ?? 0,
      trend: list
          .map((e) => AccuracyTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'periodDays': periodDays,
      'trend': trend.map((e) => e.toJson()).toList(),
    };
  }
}
