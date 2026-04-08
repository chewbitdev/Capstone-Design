import 'package:flutter/material.dart';
import '../../../notification/presentation/pages/notification_center_page.dart';
import '../../../guardian/presentation/pages/guardian_register_page.dart';

// 가이드라인 준수 : 공통 테마 컬러 사용
import '../../../../shared/theme/app_colors.dart';

class DependentHomePage extends StatelessWidget {
  const DependentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, 
        
        // 로고 파일 준비 전까지 임시 주석 처리 (에러 방지)
        /*
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset('assets/ikong_logo.png'),
        ),
        leadingWidth: 70,
        */

        title: const _StatusBadge(
          level: _StatusLevel.danger,
          message: '심박수 이상 감지',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GreetingCard(),
            const SizedBox(height: 24),

            const _SectionTitle('실시간 생체 데이터'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: _BiometricCard(
                    label: '심박수',
                    value: '--',
                    unit: 'bpm',
                    icon: Icons.favorite,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: _BiometricCard(
                    label: '호흡수',
                    value: '--',
                    unit: '/min',
                    icon: Icons.air,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const _SectionTitle('디바이스 상태'),
            const SizedBox(height: 12),
            _DeviceStatusCard(),

            const SizedBox(height: 28),
            const _SectionTitle('긴급 호출'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EmergencyButton(
                    label: '119 신고',
                    subLabel: '응급 신고',
                    icon: Icons.local_hospital,
                    color: AppColors.alertRed,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EmergencyButton(
                    label: '보호자 호출',
                    subLabel: '즉시 연락',
                    icon: Icons.phone_in_talk,
                    color: AppColors.primaryGreen,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const _SectionTitle('낙상 감지'),
            const SizedBox(height: 12),
            _FallDetectionCard(),

            const SizedBox(height: 28),
            const _SectionTitle('오늘의 활동'),
            const SizedBox(height: 12),
            _ActivityCard(),

            const SizedBox(height: 28),
            Row(
              children: [
                const _SectionTitle('등록된 보호자'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GuardianRegisterPage()),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                  label: const Text('추가', style: TextStyle(color: AppColors.primaryGreen, fontSize: 14)),
                ),
              ],
            ),
            const _GuardianCard(name: '보호자 1', relation: '자녀', phone: '010-0000-0000', isPrimary: true),
            const SizedBox(height: 12),
            const _GuardianCard(name: '보호자 2', relation: '자녀', phone: '010-0000-0000', isPrimary: false),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 이하 하단 위젯들은 디자인 가이드의 컬러 시스템을 사용하도록 모두 수정되었습니다.

class _GreetingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.background,
            child: Icon(Icons.person, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안녕하세요', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('홍길동 님', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('정상', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ),
              const SizedBox(height: 4),
              const Text('모든 수치 안정적', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}

class _BiometricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _BiometricCard({required this.label, required this.value, required this.unit, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primaryGreen),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(unit, style: const TextStyle(fontSize: 14, color: Colors.grey))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.watch, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          const Text('웨어러블 기기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text('연결 안됨', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _EmergencyButton({required this.label, required this.subLabel, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(subLabel, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _FallDetectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.accessibility_new, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('낙상 감지 모니터링', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text('마지막 감지: 없음', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Text('대기 중', style: TextStyle(color: AppColors.primaryGreen.withOpacity(0.7), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActivityItem(icon: Icons.nightlight_round, label: '수면', value: '--'),
          _ActivityItem(icon: Icons.directions_walk, label: '활동', value: '--'),
          _ActivityItem(icon: Icons.exit_to_app, label: '외출', value: '--'),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ActivityItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;

  const _GuardianCard({required this.name, required this.relation, required this.phone, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.background, child: Icon(Icons.person_outline, color: AppColors.primaryGreen)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('$name ($relation)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  if (isPrimary) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(4)),
                      child: const Text('주 보호자', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              Text(phone, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

enum _StatusLevel { normal, warning, danger }

class _StatusBadge extends StatelessWidget {
  final _StatusLevel level;
  final String message;
  const _StatusBadge({required this.level, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: level == _StatusLevel.danger ? AppColors.alertRed : AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}