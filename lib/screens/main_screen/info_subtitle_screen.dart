import 'package:flutter/material.dart';

class InfoSubtitleScreen extends StatelessWidget {
  final String headerTitle;      // 상단 큰 제목 (예: 선택한 타이틀)
  final String headerSubtitle;   // 작은 안내 문구
  final List<String> subtitles;
  final void Function(int index, String subtitle)? onSubtitleTap;
  final VoidCallback? onBack;

  const InfoSubtitleScreen({
    super.key,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.subtitles,
    this.onSubtitleTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(onBack: onBack),
        const SizedBox(height: 8),

        _TigerHeader(
          title: headerTitle,
          subtitle: headerSubtitle,
        ),

        const SizedBox(height: 32),

        Expanded(
          child: ListView.separated(
            itemCount: subtitles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = subtitles[index];
              return _SubtitleCard(
                title: sub,
                onTap: () => onSubtitleTap?.call(index, sub),
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

class _TigerHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TigerHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // ⬅️ 여기 center!
      children: [
        // 호랑이
        SizedBox(
          width: 80,
          height: 120, // ⬅️ 네가 바꿔준 120 유지
          child: Image.asset(
            'assets/images/tiger_image.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 12),

        // 말풍선 카드
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
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF858494),
                    fontSize: 14,
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



class _SubtitleCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SubtitleCard({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10), // 좌우 10px
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 26,
                  color: Color(0xFF4E7C88),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
