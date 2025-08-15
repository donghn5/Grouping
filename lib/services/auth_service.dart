import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._() {
    // 웹에서는 생성하지 않음(클라이언트ID 필요 오류 방지)
    if (!kIsWeb) {
      _google = GoogleSignIn(scopes: const ['email', 'profile']);
    }
  } // ← 세미콜론 제거
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  GoogleSignIn? _google; // 모바일에서만 세팅됨

  /// 앱 전역에서 구독할 현재 사용자
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  Future<void> init() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL); // 웹: 자동 로그인 유지
    }
    _auth.authStateChanges().listen((u) async {
      currentUser.value = u;
      if (u != null) await _ensureUserDoc(u); // 최초 로그인 시 users 문서 생성/갱신
    });
  }

  /// Google 로그인 → Firebase Auth 세션 생성
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return await _auth.signInWithPopup(provider);
    } else {
      // _google는 모바일에서만 초기화되므로 !로 단언
      final acc = await _google!.signIn();
      if (acc == null) throw Exception('사용자가 취소했습니다.');
      final gAuth = await acc.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      return await _auth.signInWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try { await _google?.disconnect(); } catch (_) {} // ?. 로 안전 호출
      try { await _google?.signOut(); } catch (_) {}
    }
    await _auth.signOut();
  }

  Future<void> _ensureUserDoc(User u) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(u.uid);
    await ref.set({
      'uid': u.uid,
      'name': u.displayName,
      'email': u.email,
      'photoUrl': u.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

