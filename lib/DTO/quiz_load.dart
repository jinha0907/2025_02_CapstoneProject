// lib/DTO/quiz_load.dart
import 'dart:convert';

class QuizHeader {
  final int quizId;
  final String category;
  final String difficulty; // "EASY", "NORMAL", "HARD"

  QuizHeader({
    required this.quizId,
    required this.category,
    required this.difficulty,
  });

  factory QuizHeader.fromJson(Map<String, dynamic> json) {
    return QuizHeader(
      quizId: json['quizId'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

class QuizLoadItem {
  final int detailId;
  final QuizHeader quizHeader;
  final String question;
  final List<String> choices;   // 파싱된 보기 리스트
  final String answer;
  final String explanation;     // ✅ 이제 단일 문자열 설명

  QuizLoadItem({
    required this.detailId,
    required this.quizHeader,
    required this.question,
    required this.choices,
    required this.answer,
    required this.explanation,
  });

  factory QuizLoadItem.fromJson(Map<String, dynamic> json) {
    // ✅ 응답에서 choices 는 여전히 "JSON 배열 문자열"
    final rawChoices = json['choices'] as String;

    final decodedChoices = (jsonDecode(rawChoices) as List)
        .map((e) => e.toString())
        .toList();

    return QuizLoadItem(
      detailId: json['detailId'] as int,
      quizHeader: QuizHeader.fromJson(
        json['quizHeader'] as Map<String, dynamic>,
      ),
      question: json['question'] as String,
      choices: decodedChoices,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String, // ✅ 그대로 문자열 사용
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailId': detailId,
      'quizHeader': quizHeader.toJson(),
      'question': question,
      // 서버 포맷에 맞추려면 다시 문자열로 인코딩
      'choices': jsonEncode(choices),
      'answer': answer,
      // ✅ explanation 은 이제 단일 문자열
      'explanation': explanation,
    };
  }
}
