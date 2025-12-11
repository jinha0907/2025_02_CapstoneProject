// lib/DTO/quiz_category_performance.dart

class CategoryPerformanceItem {
  final String category;
  final int count;

  CategoryPerformanceItem({
    required this.category,
    required this.count,
  });

  factory CategoryPerformanceItem.fromJson(Map<String, dynamic> json) {
    return CategoryPerformanceItem(
      category: json['category'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
    };
  }
}

class UserCategoryPerformanceStats {
  final int userId;
  final List<CategoryPerformanceItem> mostCorrect;
  final List<CategoryPerformanceItem> mostWrong;

  UserCategoryPerformanceStats({
    required this.userId,
    required this.mostCorrect,
    required this.mostWrong,
  });

  factory UserCategoryPerformanceStats.fromJson(Map<String, dynamic> json) {
    final List<dynamic> correctList =
        json['mostCorrect'] as List<dynamic>? ?? [];
    final List<dynamic> wrongList = json['mostWrong'] as List<dynamic>? ?? [];

    return UserCategoryPerformanceStats(
      userId: json['userId'] as int? ?? 0,
      mostCorrect: correctList
          .map(
              (e) => CategoryPerformanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostWrong: wrongList
          .map(
              (e) => CategoryPerformanceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mostCorrect': mostCorrect.map((e) => e.toJson()).toList(),
      'mostWrong': mostWrong.map((e) => e.toJson()).toList(),
    };
  }
}
