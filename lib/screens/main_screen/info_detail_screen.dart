import 'package:flutter/material.dart';

class InfoDetailScreen extends StatelessWidget {
  final String headerTitle;   // '퀴즈 정보 모음', '생활 정보 모음'
  final String mainTitle;     // 메인 제목
  final String? subTitle;     // culture: subsubtitle, life: subtitle
  final Future<String> Function() loadDetail;
  final VoidCallback? onBack;

  const InfoDetailScreen({
    super.key,
    required this.headerTitle,
    required this.mainTitle,
    this.subTitle,
    required this.loadDetail,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(onBack: onBack),
        const SizedBox(height: 8),

        /// ⭐ 변경된 상단: 호랑이 + 말풍선
        _TigerHeader(
          mainTitle: mainTitle,
          subTitle: subTitle,
        ),

        const SizedBox(height: 20),

        /// 내용 영역
        Expanded(
          child: FutureBuilder<String>(
            future: loadDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    '내용을 불러오지 못했어요.\n잠시 후 다시 시도해 주세요.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final text = snapshot.data ?? '표시할 내용이 없습니다.';

              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 14,
                      height: 1.5,
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

class _TopBar extends StatelessWidget {
  final VoidCallback? onBack;

  const _TopBar({this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// ⭐ 새로 작성된 호랑이 + 말풍선 Header
class _TigerHeader extends StatelessWidget {
  final String mainTitle;
  final String? subTitle;

  const _TigerHeader({
    required this.mainTitle,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 호랑이 이미지
        SizedBox(
          width: 80,
          height: 120,
          child: Image.asset(
            'assets/images/tiger_image.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),

        // 말풍선 스타일 박스
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  mainTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (subTitle != null && subTitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subTitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
