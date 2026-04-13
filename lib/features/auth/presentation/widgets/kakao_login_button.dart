import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import '../../../home/presentation/pages/dependent_home_page.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      // 1. 카카오 OAuth 토큰 발급
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint('=== KAKAO TOKEN ===');
      debugPrint('accessToken: ${token.accessToken}');
      debugPrint('===================');

      // 2. 백엔드로 카카오 액세스 토큰 전송 → JWT 발급
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/v1/auth/login',
        data: {
          'kakaoAccessToken': token.accessToken,
          'userType': 'USER',
        },
      );

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final isNewUser = response.data['newUser'] as bool;

      debugPrint('JWT 발급 성공 / 신규유저: $isNewUser');
      debugPrint('accessToken: $accessToken');

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DependentHomePage()),
        );
      }
    } on KakaoAuthException catch (e) {
      debugPrint('카카오 인증 오류: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 인증 오류: ${e.message}')),
        );
      }
    } on DioException catch (e) {
      debugPrint('서버 연동 오류: ${e.response?.data}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연동에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      debugPrint('로그인 오류: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _login(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: const Color(0xFF191919),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KakaoIcon(),
            SizedBox(width: 8),
            Text(
              '카카오로 시작하기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191919),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _KakaoPainter()),
    );
  }
}

class _KakaoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF191919);
    final cx = size.width / 2;
    final cy = size.height / 2 - size.height * 0.05;
    final rx = size.width * 0.5;
    final ry = size.height * 0.44;

    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    ));

    final tail = Path();
    tail.moveTo(cx - size.width * 0.1, cy + ry * 0.7);
    tail.lineTo(cx - size.width * 0.22, cy + ry * 1.35);
    tail.lineTo(cx + size.width * 0.08, cy + ry * 0.85);
    tail.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
