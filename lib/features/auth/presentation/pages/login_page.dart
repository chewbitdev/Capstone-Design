import 'package:flutter/material.dart';
import '../widgets/kakao_login_button.dart';
import '../../../../shared/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 1. 화면 전체를 덮는 더욱 활기차고 눈에 띄는 그라데이션 배경
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // 🌟 변경 포인트: 더 밝고 상쾌한 연두색에서 깊고 진한 초록색으로 이어지는 확실한 대비 적용
            colors: [
              Color(0xFF99D18F), // 밝고 상쾌한 연두색
              Color(0xFF1B5E20), // 깊고 진한 초록색
            ],
            begin: Alignment.topCenter, // 위쪽 중앙에서 시작하여
            end: Alignment.bottomCenter, // 아래쪽 중앙으로 부드럽게 이어지는 더 확연한 그라데이션
          ),
        ),
        child: SafeArea(
          bottom: false, // 하단 흰색 둥근 카드가 끝까지 덮이도록 설정
          child: Column(
            children: [
              // 🌟 2. 힙한 타이포그래피 로고 영역 (상단 중앙) - 그대로 유지
              const Expanded(
                flex: 4, // 상단 로고 영역이 차지하는 비율
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'iKong',
                        style: TextStyle(
                          fontSize: 64, // 아주 크고 시원하게
                          fontWeight: FontWeight.w900, // 가장 굵은 폰트
                          color: Colors.white,
                          letterSpacing: -2.5, // 자간을 확 좁혀서 로고타입 폼 미치게! 그대로 유지
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '스마트 건강 모니터링 서비스',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🌟 3. 하단 로그인 버튼 영역 (하얀색 둥근 카드로 깔끔하게 분리) - 그대로 유지
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), // 위쪽 모서리만 둥글게
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '피보호자로 시작하기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 배치가 좋았던 기존 카카오 로그인 버튼 유지!
                    const KakaoLoginButton(),

                    const SizedBox(height: 24),

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

                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '보호자로 로그인',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 하단 약관 안내
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}