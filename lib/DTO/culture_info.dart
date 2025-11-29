class CultureInfo {
  final int infoId;
  final String title;
  final String subtitle;
  final String subsubtitle;
  final String explanation;

  CultureInfo({
    required this.infoId,
    required this.title,
    required this.subtitle,
    required this.subsubtitle,
    required this.explanation,
  });

  factory CultureInfo.fromJson(Map<String, dynamic> json) {
    return CultureInfo(
      infoId: (json['infoId'] as num).toInt(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      subsubtitle: json['subsubtitle'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
