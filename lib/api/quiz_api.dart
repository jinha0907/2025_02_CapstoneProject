import 'package:dio/dio.dart';
import 'api_client.dart';

import '../DTO/quiz_load.dart';
import '../DTO/quiz_result_request.dart';
import '../DTO/quiz_result_response.dart';

class QuizApi {
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
}
