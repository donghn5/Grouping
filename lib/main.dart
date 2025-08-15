import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'homescreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'grouping',
      debugShowCheckedModeBanner: false, // ← 선택
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      // 선택: 네임드 라우트
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

