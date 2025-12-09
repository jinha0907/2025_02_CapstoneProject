import 'dart:async';
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

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  String _heroText = '한국 문화 교육을 위한 앱, HanQ입니다. 환영합니다!';

  Difficulty? _difficulty;
  int? _dailyCount;

  bool _isSubmitting = false;
  String? _submitError;

  // 상단 토스트 메시지 상태
  String? _toastMessage;
  bool _showToast = false;
  Timer? _toastTimer;

  void _showTopToast(String message) {
    _toastTimer?.cancel(); // 이전 타이머가 있으면 취소

    setState(() {
      _toastMessage = message;
      _showToast = true;
    });

    _toastTimer = Timer(const Duration(seconds: 2, milliseconds: 500), () {
      _hideToast();
    });
  }

  void _hideToast() {
    _toastTimer?.cancel();
    if (mounted && _showToast) {
      setState(() {
        _showToast = false;
      });
    }
  }

  void _handleNextStep() {
    _hideToast();
    if (step == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        setState(() {
          _heroText = '입력한 내용을 다시 한 번 확인해 주세요.';
        });
        return;
      }
      setState(() {
        _heroText = '한국 문화 교육을 위한 앱, HanQ입니다. 환영합니다!';
        step = 1;
      });
    } else if (step == 1) {
      if (_difficulty == null) {
        _showTopToast('퀴즈 난이도를 선택해 주세요.');
        return;
      }
      setState(() => step = 2);
    } else if (step == 2) {
      if (_dailyCount == null) {
        _showTopToast('하루에 풀 퀴즈 개수를 선택해 주세요.');
        return;
      }
      // ✅ 여기서 바로 회원가입 + 설정 API 호출
      _submitAllAndFinish();
    }
  }

  Future<void> _submitAllAndFinish() async {
    _hideToast();
    if (_isSubmitting) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => step = 0);
      return;
    }
    if (_difficulty == null || _dailyCount == null) {
      _showTopToast('난이도와 학습량을 모두 선택해 주세요.');
      setState(() => step = 1);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final signupReq = SignupRequest(
        email: email,
        password: password,
        nickname: name,
      );

      final user = await AuthApi.signup(signupReq);

      if (!mounted) return;

      // 🔹 일반 실패(null) 처리 (409는 AuthApi에서 throw로 올라옴)
      if (user == null) {
        setState(() {
          _submitError = '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      final userId = user.userId;
      final difficultyStr = _difficulty!.name;

      final diffRes = await SettingsApi.updateDifficulty(
        userId: userId,
        difficulty: difficultyStr,
      );

      if (!mounted) return;
      if (diffRes == null) {
        setState(() {
          _submitError = '난이도 설정에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      final countRes = await SettingsApi.updateQuestionCount(
        userId: userId,
        count: _dailyCount!,
      );

      if (!mounted) return;
      if (countRes == null) {
        setState(() {
          _submitError = '학습량 설정에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        return;
      }

      // ✅ API 전체 성공 → 완료 화면(step 3)으로 이동
      setState(() {
        step = 3;
      });
    } catch (e) {
      if (!mounted) return;

      // 🔥 409 Conflict (중복 이메일) 처리
      if (e.toString().contains('409')) {
        setState(() {
          step = 0; // 첫 화면으로 이동
          _heroText = '중복되는 이메일입니다. 다른 이메일을 입력해 주세요.';
          _submitError = null; // 하단 에러 메시지는 숨김

          // 비밀번호 / 난이도 / 학습량 초기화
          _pwCtrl.clear();
          _pw2Ctrl.clear();
          _difficulty = null;
          _dailyCount = null;
        });
      } else {
        // 그 외 다른 에러
        setState(() {
          _submitError = '회원가입 또는 설정 저장 중 오류가 발생했습니다: $e';
        });
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.black87,
                        onPressed: () => context.go(R.login),
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
                                  : () {
                                _hideToast();
                                setState(() => step -= 1);
                              },
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
                            onPressed: _isSubmitting ? null : _handleNextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _btn,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                if (_submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 8),
                    child: Text(
                      _submitError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          // 상단 토스트 메시지 위젯
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showToast ? MediaQuery.of(context).padding.top + 10 : -100,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _toastMessage ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
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
          heroText: _heroText,
        );
      case 1:
        return _DifficultyStep(
          key: const ValueKey('difficulty'),
          selected: _difficulty,
          onSelect: (d) {
            _hideToast();
            setState(() => _difficulty = d);
          },
        );
      case 2:
        return _StudyAmountStep(
          key: const ValueKey('study'),
          selected: _dailyCount,
          onSelect: (c) {
            _hideToast();
            setState(() => _dailyCount = c);
          },
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
          // ✅ 완료 화면 버튼은 메인으로 바로 이동만
          onFinish: () async {
            context.go(R.main);
          },
        );
    }
  }
}

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
  final String heroText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: Colors.black,
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
                  validator: (v) => (v == null || v.trim().isEmpty)
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
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim());
                    return ok ? null : '올바른 이메일 형식이 아닙니다.';
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
    );
  }
}

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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

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
  final Future<void> Function() onFinish;

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
                Image.asset(
                  'assets/images/tiger_image.png',
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 20),
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
                  onPressed: isSubmitting ? null : () => onFinish(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
