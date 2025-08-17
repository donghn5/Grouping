import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart'; // HomeScreen 경로를 프로젝트에 맞게 조정하세요.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  static const String _titleText = 'Grouping-';

  // 타이핑 애니메이션: double + ceil() 사용
  late final AnimationController _typingCtrl;
  late final Animation<double> _typing;

  // 위로 올리기 애니메이션
  late final AnimationController _liftCtrl;
  late final Animation<double> _lift;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _typingCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _typing = CurvedAnimation(parent: _typingCtrl, curve: Curves.easeInOut);

    _liftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _lift = CurvedAnimation(parent: _liftCtrl, curve: Curves.easeInOutCubic);

    _typingCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 최종 프레임 강제 리빌드 → 마지막 글자 보장
        if (mounted) setState(() {});
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _liftCtrl.forward();
        });
      }
    });

    _typingCtrl.forward();
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

  // 구글 로그인(임시 스텁)
  Future<void> _onGoogleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
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
    // 레이아웃용 전체 텍스트 치수
    final tp = TextPainter(
      text: TextSpan(text: _titleText, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final runes = _titleText.runes.toList();
    final listenBoth = Listenable.merge([_typingCtrl, _liftCtrl]);

    // 화면 높이의 22%만큼 위로 이동
    const liftFactor = 0.22;
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
                      // 🔑 마지막 글자 보장: ceil() + clamp()
                      final v = _typing.value; // 0..1
                      final count = (_typingCtrl.status == AnimationStatus.completed)
                          ? runes.length
                          : (runes.length * v).ceil().clamp(0, runes.length);

                      final visible =
                          String.fromCharCodes(runes.sublist(0, count));

                      final dy = -liftTarget * _lift.value;

                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: SizedBox(
                          width: tp.width,
                          height: tp.height + 24,
                          child: Stack(
                            children: [
                              // 공간 확보용 투명 텍스트(레이아웃 고정)
                              Opacity(
                                opacity: 0,
                                child: Text(_titleText, style: _textStyle),
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

              const SizedBox(height: 16),

              // 버튼 영역
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _onGoogleSignIn,
                  icon: const Icon(Icons.login),
                  label: Text(_loading ? '로그인 중...' : 'Google로 계속하기'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : _goHomeDirect,
                child: const Text('건너뛰기'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
