import 'package:flutter/material.dart';
import '../widgets/kakao_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),

              // 앱 아이콘 + 이름
              const Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'iKong',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '건강 모니터링 서비스',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // 역할 선택 안내 텍스트
              const Text(
                '피보호자로 시작하기',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 카카오 로그인 버튼
              const KakaoLoginButton(),

              const SizedBox(height: 24),

              // 구분선
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                ],
              ),

              const SizedBox(height: 24),

              // 보호자로 전환 버튼
              OutlinedButton(
                onPressed: () {
                  // TODO: 보호자 로그인으로 이동
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '보호자로 로그인',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // 하단 약관 안내
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  '로그인 시 서비스 이용약관 및 개인정보 처리방침에 동의합니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
