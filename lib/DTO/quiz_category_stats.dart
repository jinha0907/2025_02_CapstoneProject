// lib/DTO/quiz_category_stats.dart

class CategorySolvedCount {
  final String category;
  final int solvedCount;

  CategorySolvedCount({
    required this.category,
    required this.solvedCount,
  });

  factory CategorySolvedCount.fromJson(Map<String, dynamic> json) {
    return CategorySolvedCount(
      category: json['category'] as String? ?? '',
      solvedCount: json['solvedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'solvedCount': solvedCount,
    };
  }
}

class UserCategorySolvedStats {
  final int userId;
  final List<CategorySolvedCount> categories;

  UserCategorySolvedStats({
    required this.userId,
    required this.categories,
  });

  factory UserCategorySolvedStats.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['categories'] as List<dynamic>? ?? [];
    return UserCategorySolvedStats(
      userId: json['userId'] as int? ?? 0,
      categories: list
          .map((e) => CategorySolvedCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}
