// lib/screens/info_detail_screen.dart
import 'package:flutter/material.dart';

/// 실제 내용(긴 텍스트)을 보여주는 디테일 화면
class InfoDetailScreen extends StatelessWidget {
  /// 상단에 보여줄 카테고리 이름 (예: '한국의 일상생활')
  final String categoryTitle;

  /// 말풍선 첫 줄 제목 (예: '한국 문화 생활 정보 01')
  final String pageTitle;

  /// 말풍선 두 번째 줄 소제목 (InfoPageScreen에서 선택한 subtitle)
  final String pageSubtitle;

  /// 디테일 내용을 백엔드에서 불러오는 함수
  /// (category, title, subtitle) -> Future<String>
  final Future<String> Function(
      String category,
      String title,
      String subtitle,
      ) loadDetail;

  /// 뒤로가기 (페이지 리스트로 돌아가기)
  final VoidCallback? onBack;

  const InfoDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.loadDetail,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBarWithBack(
          onBack: onBack,
          categoryTitle: categoryTitle,
        ),
        const SizedBox(height: 8),
        _DetailHeader(
          title: pageTitle,
          subtitle: pageSubtitle, // ★ 호랑이 오른쪽 말풍선에 subtitle 사용
        ),
        const SizedBox(height: 24),

        // ===== 디테일 내용: 백엔드에서 비동기로 불러오기 =====
        Expanded(
          child: FutureBuilder<String>(
            future: loadDetail(categoryTitle, pageTitle, pageSubtitle),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '내용을 불러오는 중 오류가 발생했습니다.',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              final content = snapshot.data ?? '';

              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 상단 뒤로가기 + 카테고리 이름
class _TopBarWithBack extends StatelessWidget {
  final VoidCallback? onBack;
  final String categoryTitle;

  const _TopBarWithBack({
    this.onBack,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        const SizedBox(width: 4),
        Text(
          categoryTitle,
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// 상단 호랑이 + 말풍선 헤더
class _DetailHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DetailHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 90,
          height: 120,
          child: Image.asset(
            'assets/images/tiger_image.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F6),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF858494),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
