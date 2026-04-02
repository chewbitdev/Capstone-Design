import 'package:flutter/material.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 카카오 로그인 연동
        },
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
    // 카카오 말풍선 심볼 근사치
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2 - size.height * 0.05;
    final rx = size.width * 0.5;
    final ry = size.height * 0.44;

    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    ));

    // 말풍선 꼬리
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
