import 'package:dio/dio.dart';

import '../DTO/user_response.dart';
import '../DTO/user_settings_response.dart';
import '../info/user_info.dart';
import 'api_client.dart';

class SettingsApi {
  static Dio get _dio => ApiClient.dio;

  /// 난이도 변경
  static Future<UserSettingsResponse?> updateDifficulty({
    required int userId,
    required String difficulty,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId/settings/difficulty',
        queryParameters: {
          'difficulty': difficulty,
        },
      );

      if ((response.statusCode ?? 0) ~/ 100 == 2) {
        final data = response.data;
        if (data == null) return null;

        final settings = UserSettingsResponse.fromJson(data);

        // ==== UserSession 갱신 ====
        final current = UserInfo.currentUser;
        if (current != null) {
          UserInfo.setUser(
            UserResponse(
              userId: current.userId,
              email: current.email,
              nickname: current.nickname,
              tier: current.tier,
              totalExp: current.totalExp,
              difficulty: settings.difficulty, // 서버 값 반영
              questionCount: settings.questionCount, // 서버 값 반영
            ),
          );
        }

        return settings;
      }

      return null;
    } catch (e) {
      print('난이도 변경 실패: $e');
      return null;
    }
  }

  /// 학습량 변경
  static Future<UserSettingsResponse?> updateQuestionCount({
    required int userId,
    required int count,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId/settings/question-count',
        queryParameters: {
          'count': count,
        },
      );

      if ((response.statusCode ?? 0) ~/ 100 == 2) {
        final data = response.data;
        if (data == null) return null;

        final settings = UserSettingsResponse.fromJson(data);

        // ==== UserSession 갱신 ====
        final current = UserInfo.currentUser;
        if (current != null) {
          UserInfo.setUser(
            UserResponse(
              userId: current.userId,
              email: current.email,
              nickname: current.nickname,
              tier: current.tier,
              totalExp: current.totalExp,
              difficulty: settings.difficulty, // 서버 값 반영
              questionCount: settings.questionCount, // 서버 값 반영
            ),
          );
        }

        return settings;
      }

      return null;
    } catch (e) {
      print('학습량 변경 실패: $e');
      return null;
    }
  }
}
