import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart'; // R.main 등 사용
import '../api/auth_api.dart';
import '../api/settings_api.dart'; // 🔥 난이도/학습량 설정 API
import '../DTO/signup_request.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

enum Difficulty { easy, normal, hard }

class _SignupScreenState extends State<SignupScreen> {
  static const _bg = Color(0xFFEDE8E3);
  static const _btn = Color(0xFF4E7C88);

  int step = 0;

  // 회원가입 폼 컨트롤러
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  // 호랑이 오른쪽 텍스트 (검은색 고정)
  String _heroText = '한국 문화 교육을 위한 앱, HanQ입니다. 환영합니다!';

  // 난이도 / 학습량 상태
  Difficulty? _difficulty;
  int? _dailyCount;

  // 회원가입 후 받은 userId
  int? _userId;

  // 요청 상태
  bool _isSubmitting = false;
  String? _submitError;

  // (원래 있던 검증 로직 - 원하면 step 0에서 같이 쓸 수 있음)
  bool _validateAndNextFromSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => step = 1);
      return true;
    }
    return false;
  }

  /// 1단계: 회원가입 (1번째 화면의 버튼 클릭 시)
  Future<void> _submitSignupStep() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text.trim();

    // 필수값 확인 -> 호랑이 오른쪽 텍스트로 안내 (검은색 유지)
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _heroText = '이름, 이메일, 비밀번호를 모두 입력해 주세요.';
      });
      return;
    }

    // 비밀번호 재확인, 이메일 형식 등 폼 검증
    if (!(_formKey.currentState?.validate() ?? false)) {
      // 폼 에러가 있으면 텍스트만 살짝 바꿔줘도 됨 (선택)
      setState(() {
        _heroText = '입력한 내용을 다시 한 번 확인해 주세요.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
      // 서버 요청 시작하면 다시 기본 안내 문구로 돌려놓기 (선택사항)
      _heroText = '한국 문화 교육을 위한 앱, HanQ입니다. 환영합니다!';
    });

    try {
      final req = SignupRequest(
        email: email,
        password: password,
        nickname: name,
      );

      final user = await AuthApi.signup(req);

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _submitError = '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      // 회원가입 성공 → userId 저장 후 step 1(난이도 선택)로 이동
      setState(() {
        _userId = user.userId;
        step = 1;
      });

      _showSnack('회원가입이 완료되었습니다. 난이도를 선택해 주세요.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = '회원가입 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// 2단계: 난이도 설정 (2번째 화면의 버튼 클릭 시)
  Future<void> _submitDifficultyStep() async {
    if (_difficulty == null) {
      _showSnack('난이도를 선택해 주세요.');
      return;
    }
    if (_userId == null) {
      _showSnack('유저 정보가 없습니다. 다시 로그인하거나 회원가입을 시도해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      // enum -> 서버 문자열 (easy / normal / hard)
      final difficultyStr = _difficulty!.name;

      final result = await SettingsApi.updateDifficulty(
        userId: _userId!,
        difficulty: difficultyStr,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _submitError = '난이도 설정에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      // 성공하면 step 2(학습량 선택)으로 이동
      setState(() {
        step = 2;
      });

      _showSnack('난이도 설정이 완료되었습니다. 학습량을 선택해 주세요.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = '난이도 설정 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// 3단계: 학습량 설정 (3번째 화면의 버튼 클릭 시)
  Future<void> _submitStudyAmountStep() async {
    if (_dailyCount == null) {
      _showSnack('하루 학습 문제 수를 선택해 주세요.');
      return;
    }
    if (_userId == null) {
      _showSnack('유저 정보가 없습니다. 다시 로그인하거나 회원가입을 시도해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final result = await SettingsApi.updateQuestionCount(
        userId: _userId!,
        count: _dailyCount!,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _submitError = '학습량 설정에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      // 성공하면 step 3(완료 화면)으로 이동
      setState(() {
        step = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = '학습량 설정 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// 4단계: 완료 화면에서 메인으로 이동
  void _finishFlow() {
    context.go(R.main);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // 🔺 오른쪽 위 X 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.black87,
                    onPressed: () {
                      // 로그인 화면으로 이동
                      context.go(R.login); // 💡 라우터에서 로그인 경로 이름에 맞게 수정
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
            // ✅ 완료 단계(step == 3)에서는 하단 공통 버튼 숨김 (원래대로 유지)
            if (step < 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    if (step > 0 && step < 3)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => step -= 1),
                          style: OutlinedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: _btn),
                            foregroundColor: Colors.white,
                            backgroundColor: _btn.withOpacity(0.4),
                          ),
                          child: const Text('이전'),
                        ),
                      ),
                    if (step > 0 && step < 3) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                          if (step == 0) {
                            // 1번째 화면: 회원가입
                            _submitSignupStep();
                          } else if (step == 1) {
                            // 2번째 화면: 난이도 설정
                            _submitDifficultyStep();
                          } else if (step == 2) {
                            // 3번째 화면: 학습량 설정
                            _submitStudyAmountStep();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _btn,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : const Text(
                          '다음',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 에러 메시지 간단히 아래에 표시 (선택)
            if (_submitError != null)
              Padding(
                padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                child: Text(
                  _submitError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _SignupStep(
          key: const ValueKey('signup'),
          formKey: _formKey,
          nameCtrl: _nameCtrl,
          emailCtrl: _emailCtrl,
          pwCtrl: _pwCtrl,
          pw2Ctrl: _pw2Ctrl,
          heroText: _heroText, // 🔥 추가: 동적 텍스트 전달
        );
      case 1:
        return _DifficultyStep(
          key: const ValueKey('difficulty'),
          selected: _difficulty,
          onSelect: (d) => setState(() => _difficulty = d),
        );
      case 2:
        return _StudyAmountStep(
          key: const ValueKey('study'),
          selected: _dailyCount,
          onSelect: (c) => setState(() => _dailyCount = c),
        );
      case 3:
      default:
        return _CompleteStep(
          key: const ValueKey('complete'),
          name: _nameCtrl.text,
          difficulty: _difficulty,
          count: _dailyCount,
          isSubmitting: _isSubmitting,
          errorText: _submitError,
          onFinish: _finishFlow,
        );
    }
  }
}

//
// ========== Step 0: 기본 회원가입 정보 입력 ==========
class _SignupStep extends StatelessWidget {
  const _SignupStep({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.pwCtrl,
    required this.pw2Ctrl,
    required this.heroText,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController pwCtrl;
  final TextEditingController pw2Ctrl;
  final String heroText; // 🔥 추가: 호랑이 오른쪽 문구

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 호랑이 + 텍스트 (호랑이 크게)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      heroText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: Colors.black, // ✅ 항상 검은색
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _InputField(
                      label: '사용자 명을 입력하세요.',
                      controller: nameCtrl,
                      keyboardType: TextInputType.name,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? '이름을 입력해 주세요.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: '이메일을 입력하세요.',
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return '이메일을 입력해 주세요.';
                        }
                        final ok =
                        RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim());
                        return ok
                            ? null
                            : '올바른 이메일 형식이 아닙니다.';
                      },
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: '비밀번호를 입력하세요.',
                      controller: pwCtrl,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return '6자 이상 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: '비밀번호를 다시 입력하세요.',
                      controller: pw2Ctrl,
                      obscureText: true,
                      validator: (v) {
                        if (v != pwCtrl.text) {
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// ========== Step 1: 난이도 선택 ==========
class _DifficultyStep extends StatelessWidget {
  const _DifficultyStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final Difficulty? selected;
  final void Function(Difficulty) onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 호랑이 + 텍스트
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '퀴즈 난이도를 선택해 주세요.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _ChoiceButton(
                title: '쉬운 난이도: 기본 상식과 쉬운 퀴즈',
                subtitle: '',
                selected: selected == Difficulty.easy,
                onTap: () => onSelect(Difficulty.easy),
              ),
              const SizedBox(height: 19),
              _ChoiceButton(
                title: '중간 난이도: 기본 상식과 중간 수준의 퀴즈',
                subtitle: '',
                selected: selected == Difficulty.normal,
                onTap: () => onSelect(Difficulty.normal),
              ),
              const SizedBox(height: 19),
              _ChoiceButton(
                title: '어려운 난이도: 어려운 수준의 상식 퀴즈',
                subtitle: '',
                selected: selected == Difficulty.hard,
                onTap: () => onSelect(Difficulty.hard),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// ========== Step 2: 하루 학습량 선택 ==========
class _StudyAmountStep extends StatelessWidget {
  const _StudyAmountStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int? selected;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 호랑이 + 텍스트
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/tiger_image.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '하루에 풀 퀴즈 개수를 선택해 주세요.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              for (final n in const [3, 5, 7, 9]) ...[
                _ChoiceButton(
                  title: '$n 문제',
                  subtitle: '',
                  selected: selected == n,
                  onTap: () => onSelect(n),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

//
// ========== Step 3: 완료 화면 ==========
class _CompleteStep extends StatelessWidget {
  const _CompleteStep({
    super.key,
    required this.name,
    required this.difficulty,
    required this.count,
    required this.isSubmitting,
    required this.errorText,
    required this.onFinish,
  });

  final String name;
  final Difficulty? difficulty;
  final int? count;
  final bool isSubmitting;
  final String? errorText;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD7CEC3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 왼쪽 호랑이
                Image.asset(
                  'assets/images/tiger_image.png',
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 20),
                // 오른쪽 텍스트
                const Expanded(
                  child: Text(
                    '설정이 완료되었어요!\n\n메인페이지로 넘어갈게요',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E7C88),
                    foregroundColor: const Color(0xFFF4F3F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    '메인 페이지로',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// ---------- 공용 위젯들 ----------

class _InputField extends StatelessWidget {
  const _InputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8391A1),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF9EB2B6)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF4E7C88) : const Color(0xFFD7CEC3);
    final fg = selected ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
            BoxShadow(
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.15),
            ),
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: fg,
                fontSize: 16,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: fg.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
