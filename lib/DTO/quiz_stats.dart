// lib/DTO/quiz_stats.dart
class WeeklyQuizCount {
  final String date; // "2025-11-24"
  final int count;

  WeeklyQuizCount({
    required this.date,
    required this.count,
  });

  factory WeeklyQuizCount.fromJson(Map<String, dynamic> json) {
    return WeeklyQuizCount(
      date: json['date'] as String,
      count: json['count'] as int,
    );
  }
}
