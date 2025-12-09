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
  final String explanation;     // ✅ 단일 설명
  final String hint;            // ✅ 새로 추가된 힌트

  QuizLoadItem({
    required this.detailId,
    required this.quizHeader,
    required this.question,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.hint,
  });

  factory QuizLoadItem.fromJson(Map<String, dynamic> json) {
    // ✅ 응답에서 choices 는 "JSON 배열 문자열"
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
      explanation: json['explanation'] as String,
      hint: (json['hint'] as String?) ?? '', // 혹시 null이면 빈 문자열
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailId': detailId,
      'quizHeader': quizHeader.toJson(),
      'question': question,
      'choices': jsonEncode(choices),
      'answer': answer,
      'explanation': explanation,
      'hint': hint,
    };
  }
}
