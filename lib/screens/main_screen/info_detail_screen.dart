import 'package:flutter/material.dart';

class InfoDetailScreen extends StatelessWidget {
  /// 상단 카테고리 이름 (예: '퀴즈 정보 모음', '생활 정보 모음')
  final String headerTitle;

  /// 상단 메인 제목 (culture: 서브타이틀, life: 타이틀/서브타이틀 등)
  final String mainTitle;

  /// (선택) 메인 제목 아래에 붙는 설명 한 줄 (culture: 서브서브타이틀, life: subtitle 등)
  final String? subTitle;

  /// infoId로 내용(explanation)을 불러오는 콜백
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
        _Header(
          headerTitle: headerTitle,
          mainTitle: mainTitle,
          subTitle: subTitle,
        ),
        const SizedBox(height: 16),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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

class _Header extends StatelessWidget {
  final String headerTitle;
  final String mainTitle;
  final String? subTitle;

  const _Header({
    required this.headerTitle,
    required this.mainTitle,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFD7CEC3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.pets,
            size: 38,
            color: Color(0xFF4E7C88),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mainTitle,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (subTitle != null && subTitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subTitle!,
                  style: const TextStyle(
                    color: Color(0xFF4F4F4F),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
