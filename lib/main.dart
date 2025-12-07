// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart'; // createRouter 사용

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // ✅ hasOnboarded: 앱을 한 번이라도 켰는지 여부
  bool hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

  // 첫 실행이면 true로 바꿔서, 다음부턴 로그인부터 가게 함
  if (!hasOnboarded) {
    await prefs.setBool('hasOnboarded', true);
  }

  // ✅ 첫 실행이면 signup, 아니면 login으로 시작하는 라우터 생성
  final GoRouter router = createRouter(hasOnboarded: hasOnboarded);

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '다문화 퀴즈앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
