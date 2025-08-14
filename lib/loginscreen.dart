/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get _textStyle => GoogleFonts.pacifico(
        fontSize: 56,
        height: 1.1,
        color: Colors.black,
      );

  @override
  Widget build(BuildContext context) {
    const text = 'Grouping';

    // 전체 폭/높이(레이아웃 고정을 위해)
    final tp = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // 유니코드 안전하게 runes로 처리
    final runes = text.runes.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final v = _anim.value.clamp(0.0, 1.0);
            final count = (runes.length * v).floor().clamp(0, runes.length);
            final visible = String.fromCharCodes(runes.sublist(0, count));

            return SizedBox(
              width: tp.width,
              height: tp.height + 24,
              child: Stack(
                children: [
                  // 1) 전체 텍스트를 투명하게 깔아 공간 확보(레이아웃 고정)
                  Opacity(
                    opacity: 0,
                    child: Text(text, style: _textStyle),
                  ),
                  // 2) 왼쪽부터 한 글자씩 보여줌 (타자 효과)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(visible, style: _textStyle),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();

    // 1) 글자 타자 애니메이션
    _typingCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _typing = CurvedAnimation(parent: _typingCtrl, curve: Curves.easeInOut);

    // 2) 위로 올리기 애니메이션 (완료 후 1초 대기 뒤 시작)
    _liftCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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

    // 빨간 박스 위치 감(대략 위쪽으로 22% 만큼 이동)
    const liftFactor = 0.22; // 필요 시 0.18~0.28 사이로 미세조정
    final liftTarget = MediaQuery.of(context).size.height * liftFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: listenBoth,
          builder: (context, _) {
            final v = _typing.value.clamp(0.0, 1.0);
            final count = (runes.length * v).floor().clamp(0, runes.length);
            final visible = String.fromCharCodes(runes.sublist(0, count));

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
                    Opacity(opacity: 0, child: Text(text, style: _textStyle)),
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
    );
  }
}
