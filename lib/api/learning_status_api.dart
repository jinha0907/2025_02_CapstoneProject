// lib/api/learning_status_api.dart
//
// 학습현황 API 모음
// - 전체 정답률
// - 카테고리별 푼 문제 수
// - 많이 맞힌/틀린 카테고리
// - 정답률 트렌드

import 'package:dio/dio.dart';
import 'api_client.dart';  // ← ApiClient.dio 사용

import '../DTO/user_quiz_accuracy.dart';
import '../DTO/quiz_category_stats.dart';
import '../DTO/quiz_category_performance.dart';
import '../DTO/quiz_accuracy_trend.dart';

class LearningStatusApi {
  LearningStatusApi._internal();
  static final LearningStatusApi instance = LearningStatusApi._internal();

  /// 내부 dio = 글로벌 ApiClient.dio
  Dio get _dio => ApiClient.dio;

  /// ----------------------------------------------
  /// 🔹 전체 정답률 조회
  /// GET /quiz/stats/accuracy/{userId}
  /// ----------------------------------------------
  Future<UserQuizAccuracy> fetchUserAccuracy(int userId) async {
    try {
      final res = await _dio.get('/quiz/stats/accuracy/$userId');
      return UserQuizAccuracy.fromJson(res.data);
    } catch (e) {
      throw Exception('정답률 조회 실패: $e');
    }
  }

  /// ----------------------------------------------
  /// 🔹 카테고리별 푼 문제 수 조회
  /// GET /quiz/stats/category/{userId}
  /// ----------------------------------------------
  Future<UserCategorySolvedStats> fetchUserCategorySolved(int userId) async {
    try {
      final res = await _dio.get('/quiz/stats/category/$userId');
      return UserCategorySolvedStats.fromJson(res.data);
    } catch (e) {
      throw Exception('카테고리별 학습량 조회 실패: $e');
    }
  }

  /// ----------------------------------------------
  /// 🔹 많이 맞힌 / 틀린 카테고리 조회
  /// GET /quiz/stats/category/performance/{userId}
  /// ----------------------------------------------
  Future<UserCategoryPerformanceStats> fetchUserCategoryPerformance(
      int userId) async {
    try {
      final res = await _dio.get('/quiz/stats/category/performance/$userId');
      return UserCategoryPerformanceStats.fromJson(res.data);
    } catch (e) {
      throw Exception('카테고리별 성과 조회 실패: $e');
    }
  }

  /// ----------------------------------------------
  /// 🔹 정답률 추이(트렌드) 조회
  /// GET /quiz/stats/accuracy/trend/{userId}
  /// ----------------------------------------------
  Future<UserAccuracyTrend> fetchUserAccuracyTrend(
      int userId, {
        int days = 6, // 기본 요청 days = 6
      }) async {
    try {
      final res = await _dio.get(
        '/quiz/stats/accuracy/trend/$userId',
        queryParameters: {
          'days': days, // 🔥 서버 요구사항 (integer) 그대로 전달
        },
      );
      return UserAccuracyTrend.fromJson(res.data);
    } catch (e) {
      throw Exception('정답률 트렌드 조회 실패: $e');
    }
  }


  /// ----------------------------------------------
  /// 🔥 학습현황 탭 전체 데이터 한 번에 가져오기 (병렬 호출)
  /// ----------------------------------------------
  Future<LearningStatusBundle> fetchLearningStatusBundle(int userId) async {
    try {
      final result = await Future.wait([
        fetchUserAccuracy(userId),
        fetchUserCategorySolved(userId),
        fetchUserCategoryPerformance(userId),
        fetchUserAccuracyTrend(userId),
      ]);

      return LearningStatusBundle(
        accuracy: result[0] as UserQuizAccuracy,
        categorySolved:
        (result[1] as UserCategorySolvedStats).categories,
        categoryPerformance:
        result[2] as UserCategoryPerformanceStats,
        accuracyTrend: result[3] as UserAccuracyTrend,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// ---------------------------------------------------------
/// 🔹 학습현황 전체 데이터를 한꺼번에 담는 DTO
/// ---------------------------------------------------------
class LearningStatusBundle {
  final UserQuizAccuracy accuracy; // 전체 정답률
  final List<CategorySolvedCount> categorySolved; // 카테고리별 문제수
  final UserCategoryPerformanceStats categoryPerformance; // 많이 맞힌/틀린 카테고리
  final UserAccuracyTrend accuracyTrend; // 정답률 트렌드

  LearningStatusBundle({
    required this.accuracy,
    required this.categorySolved,
    required this.categoryPerformance,
    required this.accuracyTrend,
  });
}
