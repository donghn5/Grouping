import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/services/auth_service.dart';
import 'homescreen.dart'; // 홈 화면 이동용

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _typingCtrl;
  late final Animation<double> _typing;

  late final AnimationController _liftCtrl;
  late final Animation<double> _lift;

  bool _loading = false; // 버튼 중복 방지

  @override
  void initState() {
    super.initState();

    // 1) 글자 타자 애니메이션
    _typingCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _typing = CurvedAnimation(parent: _typingCtrl, curve: Curves.easeInOut);

    // 2) 위로 올리기 애니메이션 (완료 후 1초 대기 뒤 시작)
    _liftCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _lift = CurvedAnimation(parent: _liftCtrl, curve: Curves.easeInOutCubic);

    _typingCtrl.forward();
    _typingCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _liftCtrl.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _liftCtrl.dispose();
    super.dispose();
  }

  TextStyle get _textStyle => GoogleFonts.pacifico(
        fontSize: 56,
        height: 1.1,
        color: Colors.black,
      );

  // ⬇️ 구글 로그인(임시 스텁) — 나중에 google_sign_in 로직 연결
  Future<void> _onGoogleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHomeDirect() {
    if (_loading) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = 'Grouping';

    // 전체 폭/높이 계산(레이아웃 고정용)
    final tp = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final runes = text.runes.toList();
    final listenBoth = Listenable.merge([_typingCtrl, _liftCtrl]);

    // 대략 위쪽으로 22% 만큼 이동
    const liftFactor = 0.22; // 필요 시 0.18~0.28 사이로 미세조정
    final liftTarget = MediaQuery.of(context).size.height * liftFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // 상단 애니메이션 영역
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: listenBoth,
                    builder: (context, _) {
                      final v = _typing.value.clamp(0.0, 1.0);
                      final count =
                          (runes.length * v).floor().clamp(0, runes.length);
                      final visible =
                          String.fromCharCodes(runes.sublist(0, count));

                      // 위로 올라갈 거리 (완료 후 1초 뒤부터 시작)
                      final dy = -liftTarget * _lift.value;

                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: SizedBox(
                          width: tp.width,
                          height: tp.height + 24,
                          child: Stack(
                            children: [
                              // 공간 확보용 투명 텍스트
                              Opacity(
                                opacity: 0,
                                child: Text(text, style: _textStyle),
                              ),
                              // 왼쪽부터 한 글자씩 나타나기
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(visible, style: _textStyle),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 하단 액션 버튼들
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _onGoogleSignIn,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(
                    _loading ? 'Google로 로그인 중...' : 'Google로 계속하기',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.black.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _goHomeDirect,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('홈으로 바로 가기'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

