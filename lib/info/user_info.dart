// lib/info/user_info.dart
import '../DTO/user_response.dart';

/// 앱 실행 중 현재 로그인한 사용자 정보를 보관하는 세션 클래스
class UserInfo {
  /// 현재 로그인한 유저. 로그인 전/로그아웃 후에는 null.
  static UserResponse? currentUser;

  /// 로그인 성공 시 호출해서 세션에 사용자 정보 저장
  static void setUser(UserResponse user) {
    currentUser = user;
  }

  /// 로그아웃 또는 앱에서 사용자 정보를 비울 때 사용
  static void clear() {
    currentUser = null;
  }
}
