import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kakao_login_button.dart';

enum _Role { dependent, guardian }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  _Role _role = _Role.dependent;
  late AnimationController _animController;
  late Animation<Color?> _colorTop;
  late Animation<Color?> _colorBottom;

  static const _dependentTop = Color(0xFF7CB342);
  static const _dependentBottom = Color(0xFF558B2F);
  static const _guardianTop = Color(0xFFE53935);
  static const _guardianBottom = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _colorTop = ColorTween(begin: _dependentTop, end: _guardianTop)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _colorBottom = ColorTween(begin: _dependentBottom, end: _guardianBottom)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectRole(_Role role) {
    if (_role == role) return;
    setState(() => _role = role);
    if (role == _Role.guardian) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _colorTop.value,
          body: Stack(
            children: [
              // 그라디언트 배경
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_colorTop.value!, _colorBottom.value!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 배경 장식 원
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 220,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // 로고 영역
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Heart View',
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _role == _Role.dependent
                                    ? '건강 상태를 모니터링하고\n보호자와 연결하세요'
                                    : '소중한 가족의 건강을\n실시간으로 확인하세요',
                                key: ValueKey(_role),
                                style: GoogleFonts.notoSansKr(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.6,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 하단 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 역할 선택 토글
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                _RoleTab(
                                  label: '피보호자',
                                  selected: _role == _Role.dependent,
                                  accentColor: _dependentTop,
                                  onTap: () => _selectRole(_Role.dependent),
                                ),
                                _RoleTab(
                                  label: '보호자',
                                  selected: _role == _Role.guardian,
                                  accentColor: _guardianTop,
                                  onTap: () => _selectRole(_Role.guardian),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 카카오 로그인 버튼
                          KakaoLoginButton(isGuardian: _role == _Role.guardian),

                          const SizedBox(height: 32),

                          Text(
                            '로그인 시 서비스 이용약관 및 개인정보 처리방침에 동의합니다.',
                            style: GoogleFonts.notoSansKr(
                              textStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: MediaQuery.of(context).padding.bottom),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? accentColor : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
