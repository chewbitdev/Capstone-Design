import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/login_page.dart';

class IKongApp extends StatelessWidget {
  const IKongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iKong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'sans-serif',
      ),
      home: const LoginPage(),
    );
  }
}
