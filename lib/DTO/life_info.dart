class LifeInfo {
  final int infoId;
  final String title;
  final String subtitle;
  final String explanation;

  LifeInfo({
    required this.infoId,
    required this.title,
    required this.subtitle,
    required this.explanation,
  });

  factory LifeInfo.fromJson(Map<String, dynamic> json) {
    return LifeInfo(
      infoId: (json['infoId'] as num).toInt(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
