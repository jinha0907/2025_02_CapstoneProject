import 'package:dio/dio.dart';

import 'api_client.dart';
import '../DTO/culture_info.dart';
import '../DTO/life_info.dart';

/// 문화 / 생활 정보 구분용
enum InfoKind { culture, life }

extension InfoKindExt on InfoKind {
  /// 기본 경로
  String get basePath => this == InfoKind.culture ? '/culture' : '/life';

  /// 화면 상단에 표시할 이름
  String get label => this == InfoKind.culture ? '퀴즈 정보 모음' : '생활 정보 모음';
}

class InfoApi {
  static final Dio _dio = ApiClient.dio;

  // ==============================
  // 타이틀 목록 (/culture/titles, /life/titles)
  // ==============================

  static Future<List<String>> fetchTitles(InfoKind kind) async {
    final res = await _dio.get('${kind.basePath}/titles');
    final data = res.data;

    if (data is List) {
      // ["제목1", "제목2", ...]
      return data.map((e) => e.toString()).toList();
    } else if (data is Map<String, dynamic>) {
      // { "titles": ["제목1", "제목2"] } 같은 형식도 지원
      final list = data['titles'];
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // ==============================
  // culture: 특정 title 의 목록
  //   GET /culture/title/{title}/subtitles
  //   → List<CultureInfoDTO> 라고 가정
  // ==============================

  static Future<List<CultureInfo>> fetchCultureInfosByTitle(
      String title,
      ) async {
    final res = await _dio.get('/culture/title/$title/subtitles');
    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CultureInfo.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      // { "items": [ {...}, {...} ] } 또는 { "subtitles": [ {...} ] } 형식까지 커버
      final list = data['items'] ?? data['subtitles'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(CultureInfo.fromJson)
            .toList();
      }
    }
    return [];
  }

  // ==============================
  // life: 특정 title 의 목록
  //   GET /life/title/{title}/subtitles
  //   → List<LifeInfoDTO> 라고 가정
  // ==============================

  static Future<List<LifeInfo>> fetchLifeInfosByTitle(
      String title,
      ) async {
    final res = await _dio.get('/life/title/$title/subtitles');
    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(LifeInfo.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      final list = data['items'] ?? data['subtitles'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(LifeInfo.fromJson)
            .toList();
      }
    }
    return [];
  }

  // ==============================
  // 공통: infoId 로 상세 내용 조회
  //   GET /culture/{infoId}
  //   GET /life/{infoId}
  //   → explanation 문자열만 쓰면 되므로 String으로 리턴
  // ==============================

  static Future<String> fetchDetail({
    required InfoKind kind,
    required int infoId,
  }) async {
    final res = await _dio.get('${kind.basePath}/$infoId');
    final data = res.data;

    if (data is Map<String, dynamic>) {
      // CultureInfoDTO / LifeInfoDTO 의 explanation 필드 사용
      return data['explanation']?.toString() ?? '';
    }
    return data?.toString() ?? '';
  }
}
