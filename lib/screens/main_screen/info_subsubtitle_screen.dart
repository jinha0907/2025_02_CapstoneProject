import 'package:flutter/material.dart';

class InfoSubsubtitleScreen extends StatelessWidget {
  final String headerTitle;        // 선택한 서브타이틀
  final String headerSubtitle;     // 안내 문구
  final List<String> subsubtitles; // 서브서브타이틀 목록
  final void Function(int index, String subsubtitle)? onSubsubtitleTap;
  final VoidCallback? onBack;

  const InfoSubsubtitleScreen({
    super.key,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.subsubtitles,
    this.onSubsubtitleTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(onBack: onBack),
        const SizedBox(height: 8),
        _Header(
          title: headerTitle,
          subtitle: headerSubtitle,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: subsubtitles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = subsubtitles[index];
              return _Card(
                title: s,
                onTap: () => onSubsubtitleTap?.call(index, s),
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
  final String title;
  final String subtitle;

  const _Header({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                title,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _Card({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD7CEC3),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.chevron_right,
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
    );
  }
}
