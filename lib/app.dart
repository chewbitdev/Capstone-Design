import 'dart:convert';
import 'package:flutter/material.dart';
import 'core/auth/auth_storage.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/dependent_home_page.dart';
import 'features/guardian/presentation/pages/caregiver_home_page.dart';

class IKongApp extends StatelessWidget {
  const IKongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'sans-serif',
      ),
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final token = await AuthStorage.getAccessToken();
    if (!mounted) return;

    if (token == null) {
      _go(const LoginPage());
      return;
    }

    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final payload = json.decode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;

        // 토큰 만료 확인
        final exp = payload['exp'] as int?;
        if (exp != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          if (DateTime.now().isAfter(expiry)) {
            await AuthStorage.clear();
            if (mounted) _go(const LoginPage());
            return;
          }
        }

        final userType = payload['userType'] as String?;
        if (userType == 'GUARDIAN') {
          _go(const CaregiverHomePage());
          return;
        }
      }
    } catch (_) {
      await AuthStorage.clear();
      if (mounted) _go(const LoginPage());
      return;
    }

    _go(const DependentHomePage());
  }

  void _go(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
