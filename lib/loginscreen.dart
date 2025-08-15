import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
/*
import 'package:google_sign_in/google_sign_in.dart';
l
Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
*/

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
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedBuilder(
        animation: listenBoth,
        builder: (context, _) {
          final v = _typing.value.clamp(0.0, 1.0);
          final count = (runes.length * v).floor().clamp(0, runes.length);
          final visible = String.fromCharCodes(runes.sublist(0, count));

          final dy = -liftTarget * _lift.value;

          return Transform.translate(
            offset: Offset(0, dy),
            child: SizedBox(
              width: tp.width,
              height: tp.height + 24,
              child: Stack(
                children: [
                  const Opacity(opacity: 0, child: Text(text, /* style: _textStyle */)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(visible /*, style: _textStyle*/),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
    ],
  ),
)
);

  }
}
