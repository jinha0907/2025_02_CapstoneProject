import 'package:dio/dio.dart';

import 'api_client.dart';

import '../DTO/quiz_load.dart';
import '../DTO/quiz_result_request.dart';
import '../DTO/quiz_result_response.dart';
import '../DTO/quiz_stats.dart';      // ⭐ weekly DTO
import '../info/user_info.dart';     // ⭐ userId 가져오기

class QuizApi {

  // ================================================================
  // 1) 오늘의 퀴즈 로드
  // ================================================================
  /// GET /quiz/load/{userId}
  static Future<List<QuizLoadItem>> loadQuiz(int userId) async {
    final Response response = await ApiClient.dio.get('/quiz/load/$userId');

    if (response.statusCode == 200) {
      final List data = response.data as List;
      return data
          .map((e) => QuizLoadItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('퀴즈 로드 실패: ${response.statusCode}');
    }
  }

  // ================================================================
  // 2) 퀴즈 결과 전송
  // ================================================================
  /// POST /quiz/result
  static Future<QuizResultResponse> submitQuizResult(
      QuizResultRequest request) async {
    final Response response = await ApiClient.dio.post(
      '/quiz/result',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      return QuizResultResponse.fromJson(
          response.data as Map<String, dynamic>);
    } else {
      throw Exception('퀴즈 결과 저장 실패: ${response.statusCode}');
    }
  }

  // ================================================================
  // ⭐ 3) 주간 퀴즈 풀이 수 (차트용)
  // ================================================================
  /// GET /user/quiz/weekly/{userId}
  static Future<List<WeeklyQuizCount>> fetchWeeklyQuizCounts() async {
    final user = UserInfo.currentUser;

    if (user == null) {
      throw Exception('로그인 정보가 없습니다. (userId 없음)');
    }

    final userId = user.userId; // UserInfo 모델 구조에 맞게 조정

    final Response response =
    await ApiClient.dio.get('/user/quiz/weekly/$userId');

    if (response.statusCode == 200) {
      final List<dynamic> raw = response.data as List<dynamic>;

      final list = raw
          .map((e) => WeeklyQuizCount.fromJson(e as Map<String, dynamic>))
          .toList();

      // 🔹 날짜 기준으로 정렬 (오래된 날짜 → 최근 날짜)
      //    "2025-12-03" 같은 ISO 포맷이면 문자열 비교로도 정렬 잘 됨
      list.sort((a, b) => a.date.compareTo(b.date));

      return list;
    } else {
      throw Exception(
          '주간 학습량 로드 실패: ${response.statusCode}, ${response.data}');
    }
  }

  // ================================================================
  // ⭐ 4) 전체 푼 퀴즈 개수
  // ================================================================
  /// GET /user/quiz/total/{userId}
  static Future<int> fetchTotalQuizCount() async {
    final user = UserInfo.currentUser;

    if (user == null) {
      throw Exception('로그인 정보가 없습니다. (userId 없음)');
    }

    final userId = user.userId;

    final Response response =
    await ApiClient.dio.get('/user/quiz/total/$userId');

    if (response.statusCode == 200) {
      // 200 OK → int or {"total": int}
      if (response.data is int) {
        return response.data as int;
      }

      if (response.data is Map<String, dynamic>) {
        return (response.data as Map<String, dynamic>)['total'] as int;
      }

      throw Exception('예상하지 못한 total 응답 형식: ${response.data}');
    } else {
      throw Exception(
          '전체 푼 퀴즈 개수 로드 실패: ${response.statusCode}, ${response.data}');
    }
  }
}
