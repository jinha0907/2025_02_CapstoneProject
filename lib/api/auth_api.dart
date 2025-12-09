import 'package:dio/dio.dart';

import '../DTO/login_request.dart';
import '../DTO/signup_request.dart';
import '../DTO/user_response.dart';
import '../info/user_info.dart';
import 'api_client.dart';

class AuthApi {
  /// 회원가입
  static Future<UserResponse?> signup(SignupRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/signup',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) return null;

      final user = UserResponse.fromJson(data);

      // 세션에 저장
      UserInfo.setUser(user);

      return user;
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      print('회원가입 실패 status: $status');

      // 🔥 이메일 중복 → 명확하게 throw
      if (status == 409) {
        throw Exception('409');
      }

      // 그 외 에러는 일반 실패 처리
      return null;
    } catch (e) {
      print('회원가입 실패: $e');
      return null;
    }
  }

  /// 로그인
  static Future<UserResponse?> login(LoginRequest request) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) return null;

      final user = UserResponse.fromJson(data);
      UserInfo.setUser(user);

      return user;
    } on DioException catch (e) {
      print('로그인 실패(DioException): ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('로그인 실패: $e');
      return null;
    }
  }
}
