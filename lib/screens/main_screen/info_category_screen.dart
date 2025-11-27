import 'package:flutter/material.dart';

class InfoCategoryScreen extends StatelessWidget {
  final String headerTitle;
  final String headerSubtitle;
  final List<String> categories;
  final void Function(int index, String category)? onCategoryTap;
  final VoidCallback? onBack;

  const InfoCategoryScreen({
    super.key,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.categories,
    this.onCategoryTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBarWithBack(onBack: onBack),
        const SizedBox(height: 8),
        _InfoHeader(title: headerTitle, subtitle: headerSubtitle),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == categories.length - 1 ? 0 : 12,
                ),
                child: _InfoListCard(
                  title: category,
                  onTap: () => onCategoryTap?.call(index, category),
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

class _InfoHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoHeader({required this.title, required this.subtitle});

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
              children: [
                Text(
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
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
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

class _InfoListCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _InfoListCard({
    required this.title,
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
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: Color(0xFF4E7C88),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
