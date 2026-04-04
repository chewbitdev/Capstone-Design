import 'package:flutter/material.dart';

class DependentHomePage extends StatelessWidget {
  const DependentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'iKong',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 인사말
            _GreetingCard(),
            const SizedBox(height: 16),

            // 실시간 생체 데이터
            const _SectionTitle('실시간 생체 데이터'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _BiometricCard(
                    label: '심박수',
                    value: '--',
                    unit: 'bpm',
                    icon: Icons.favorite_border,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BiometricCard(
                    label: '호흡수',
                    value: '--',
                    unit: '/min',
                    icon: Icons.air,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 디바이스 상태
            const _SectionTitle('디바이스 상태'),
            const SizedBox(height: 8),
            _DeviceStatusCard(),

            const SizedBox(height: 20),

            // 긴급 호출
            const _SectionTitle('긴급 호출'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _EmergencyButton(
                    label: '119 신고',
                    subLabel: '응급 신고',
                    icon: Icons.local_hospital_outlined,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EmergencyButton(
                    label: '보호자 호출',
                    subLabel: '즉시 연락',
                    icon: Icons.call_outlined,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 낙상 감지 상태
            const _SectionTitle('낙상 감지'),
            const SizedBox(height: 8),
            _FallDetectionCard(),

            const SizedBox(height: 20),

            // 오늘의 활동
            const _SectionTitle('오늘의 활동'),
            const SizedBox(height: 8),
            _ActivityCard(),

            const SizedBox(height: 20),

            // 보호자 목록
            const _SectionTitle('등록된 보호자'),
            const SizedBox(height: 8),
            _GuardianCard(name: '보호자 1', relation: '자녀', phone: '010-0000-0000', isPrimary: true),
            const SizedBox(height: 8),
            _GuardianCard(name: '보호자 2', relation: '자녀', phone: '010-0000-0000', isPrimary: false),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.account_circle_outlined, size: 40, color: Colors.black54),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                '홍길동 님',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '정상',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                '모든 수치 정상',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}

class _BiometricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _BiometricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Text(
            '웨어러블 기기',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '연결 안됨',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final VoidCallback onPressed;

  const _EmergencyButton({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBDBDBD)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '낙상 감지 모니터링',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 2),
              Text(
                '마지막 감지: 없음',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '대기 중',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        children: [
          Expanded(child: _ActivityItem(icon: Icons.bedtime_outlined, label: '수면시간', value: '--')),
          SizedBox(width: 12),
          Expanded(child: _ActivityItem(icon: Icons.directions_run, label: '활동시간', value: '--')),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;

  const _GuardianCard({
    required this.name,
    required this.relation,
    required this.phone,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$name ($relation)',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '주 보호자',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                phone,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
