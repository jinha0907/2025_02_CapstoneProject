import 'package:flutter/material.dart';

class InfoPageScreen extends StatelessWidget {
  final String categoryTitle;
  final List<String> titles;
  final List<String> subtitles;
  final VoidCallback? onBack;
  final void Function(int index, String title, String subtitle)? onPageTap;

  const InfoPageScreen({
    super.key,
    required this.categoryTitle,
    required this.titles,
    required this.subtitles,
    this.onBack,
    this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBarWithBack(onBack: onBack),
        const SizedBox(height: 8),
        _PageHeader(title: categoryTitle),
        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final t = titles[index];
              final sub = index < subtitles.length ? subtitles[index] : '';
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == titles.length - 1 ? 0 : 12,
                ),
                child: _PageListCard(
                  title: t,
                  subtitle: sub,
                  onTap: () => onPageTap?.call(index, t, sub),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopBarWithBack extends StatelessWidget {
  final VoidCallback? onBack;
  const _TopBarWithBack({this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;

  const _PageHeader({required this.title});

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
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F6),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PageListCard({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: Color(0xFF4E7C88),
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
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
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
          ],
        ),
      ),
    );
  }
}
