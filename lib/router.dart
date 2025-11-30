import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 로그인/회원가입/퀴즈
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';


// 메인 탭
import 'screens/main_screen/main_tab_scaffold.dart';
import '../DTO/quiz_result_request.dart'; // ㅅ'
// 설정 내부
import 'screens/main_screen/settings/difficulty_setting_screen.dart';
import 'screens/main_screen/settings/amount_setting_screen.dart';

class R {
  static const login = '/login';
  static const signup = '/signup';
  static const main = '/main';

  static const quiz = '/quiz';
  static const quizResult = '/quiz/result';

  static const learningStatus = '/learning-status';

  // 설정 탭으로 진입
  static const settings = '/settings';

  // 설정 내부
  static const difficulty = '/settings/difficulty';
  static const amountSetting = '/settings/amount';
}

final GoRouter appRouter = GoRouter(
  initialLocation: R.signup,
  routes: [
    GoRoute(
      path: R.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: R.signup,
      builder: (_, __) => const SignupScreen(),
    ),

    // 메인 탭 (0번 탭 = 메인)
    GoRoute(
      path: R.main,
      builder: (_, __) => const MainTabScaffold(),
    ),

    // 설정 탭으로 바로 들어가고 싶을 때 (필요 없으면 나중에 삭제해도 됨)
    GoRoute(
      path: R.settings,
      builder: (_, __) => const MainTabScaffold(), // 탭 인덱스는 나중에 initialIndex로 확장 가능
    ),

    GoRoute(
      path: R.quiz,
      builder: (_, __) => const QuizScreen(),
    ),
    GoRoute(
      path: R.quizResult,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final total = extra?['total'] as int? ?? 2;
        final correct = extra?['correct'] as int? ?? 1;
        final results =
            (extra?['results'] as List<QuizResultItem>?) ?? const [];

        return QuizResultScreen(
          total: total,
          correct: correct,
          results: results,
        );
      },
    ),



    // 🔹 난이도 설정
    GoRoute(
      path: R.difficulty,
      builder: (_, __) => const DifficultySettingScreen(),
    ),

    // 🔹 학습량 설정
    GoRoute(
      path: R.amountSetting,
      builder: (_, __) => const AmountSettingScreen(),
    ),
  ],
);
