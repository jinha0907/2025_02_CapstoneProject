import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../DTO/login_request.dart';
import '../api/auth_api.dart';
import '../info/user_info.dart'; // 🔥 UserSession 저장

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _bgColor = Color(0xFFEDE8E3);
  static const _primaryColor = Color(0xFF4E7C88);

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _loginFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 호랑이 이미지 미리 로드
    precacheImage(const AssetImage('assets/images/tiger_image.png'), context);
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  // ==========================
  // 🚀 로그인 요청
  // ==========================
  Future<void> _tryLogin() async {
    final email = _idController.text.trim();
    final pw = _pwController.text.trim();

    final request = LoginRequest(email: email, password: pw);

    final user = await AuthApi.login(request);

    if (user != null) {
      UserInfo.setUser(user);
      context.go(R.main);
    } else {
      setState(() {
        _loginFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 회원가입 화면의 X 버튼 줄과 같은 높이 확보 (하지만 로그인에서는 보이지 않게)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Opacity(
                    opacity: 0, // 👈 투명하게 만들어서 안 보이게만 함
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: null, // 클릭도 안됨
                    ),
                  ),
                ],
              ),
            ),

            // ✅ 나머지 내용은 스크롤 가능하게
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), // 좌우 20 통일
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ===== 호랑이 + 텍스트 박스 (Signup / Main 헤더와 동일 스타일) =====
                    Center(
                      child: SizedBox(
                        width: 340,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 110,
                                height: 140,
                                child: Image.asset(
                                  'assets/images/tiger_image.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 90,
                                padding:
                                const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                decoration: BoxDecoration(
                                  color: Colors.white, // 🔥 메인/회원가입과 동일
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _loginFailed
                                        ? '아이디 혹은 비밀번호가\n일치하지 않습니다.\n다시 입력해 주십시오'
                                        : '한국 문화 교육을 위한 앱,\nHanQ입니다.\n환영합니다!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C2C2C),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ===== 아이디 입력 =====
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '아이디를 입력하세요.',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== 비밀번호 입력 =====
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _pwController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '비밀번호를 입력하세요.',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== 로그인 버튼 =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _tryLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== 회원가입 버튼 (텍스트) =====
                    GestureDetector(
                      onTap: () {
                        context.go(R.signup);
                      },
                      child: const Center(
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
